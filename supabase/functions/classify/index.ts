import 'jsr:@supabase/functions-js@2/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!;

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    );
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) throw new Error('Unauthorized');

    const body = await req.json();
    const { action, imageUrl, storagePath, idempotencyKey, tfliteResult } = body;

    if (!imageUrl || !storagePath || !idempotencyKey) {
      throw new Error('Missing required fields: imageUrl, storagePath, idempotencyKey');
    }

    const VALID_CATEGORIES = ['organic', 'recyclable', 'hazardous', 'general'];

    if (action === 'classify') {
      // Idempotency check
      const { data: existing } = await supabaseAdmin
        .from('submissions')
        .select('id, state, category, confidence, points_awarded')
        .eq('idempotency_key', idempotencyKey)
        .maybeSingle();

      if (existing) {
        return new Response(JSON.stringify({
          submissionId: existing.id,
          state: existing.state,
          category: existing.category,
          confidence: existing.confidence,
          pointsAwarded: existing.points_awarded,
        }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
      }

      // MD5 duplicate check via image_hash
      // The Flutter client should compute the MD5 hash and send it
      // For now, skip duplicate detection (hackathon simplification)

      // Get config
      const { data: configData } = await supabaseAdmin
        .from('config')
        .select('value')
        .eq('key', 'system')
        .single();
      const config = configData?.value ?? {};
      const confidenceThreshold = config.confidenceThreshold ?? 0.7;
      const pointsPerCategory = config.pointsPerCategory ?? { organic: 10, recyclable: 15, hazardous: 20, general: 5 };

      // Get user profile
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('username')
        .eq('uid', user.id)
        .single();

      // Gemini classification - primary prompt
      const geminiResult = await classifyWithGemini(imageUrl);

      let finalCategory = geminiResult.category;
      if (!VALID_CATEGORIES.includes(finalCategory.toLowerCase())) {
        finalCategory = 'general';
      }
      let finalConfidence = geminiResult.confidence;
      let finalSubcategory = geminiResult.subcategory;
      let finalApproach = 'gemini';
      let state = 'CLASSIFIED';

      // If TFLite result available, cross-validate
      if (tfliteResult && tfliteResult.category) {
        if (tfliteResult.category.toLowerCase() === finalCategory.toLowerCase()) {
          finalConfidence = Math.max(finalConfidence, tfliteResult.confidence);
          finalApproach = 'ensemble';
        }
        // If disagreement, trust Gemini (primary)
      }

      // Check confidence threshold
      if (finalConfidence < confidenceThreshold) {
        let submission;
        try {
          const { data } = await supabaseAdmin
            .from('submissions')
            .insert({
              user_id: user.id,
              username: profile?.username ?? 'unknown',
              image_url: imageUrl,
              storage_path: storagePath,
              category: finalCategory,
              subcategory: finalSubcategory,
              confidence: finalConfidence,
              primary_approach: finalApproach,
              state: 'DISPUTED',
              idempotency_key: idempotencyKey,
              classified_at: new Date().toISOString(),
            })
            .select('id')
            .single();
          submission = data;
        } catch (insertError: any) {
          if (insertError?.code === '23505') {
            const { data: existing } = await supabaseAdmin
              .from('submissions')
              .select('id, state, category, confidence, points_awarded')
              .eq('idempotency_key', idempotencyKey)
              .single();
            return new Response(JSON.stringify({
              submissionId: existing.id,
              state: existing.state,
              category: existing.category,
              confidence: existing.confidence,
              pointsAwarded: existing.points_awarded,
            }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
          }
          throw insertError;
        }

        await supabaseAdmin.from('disputes').insert({
          submission_id: submission.id,
          submitter_id: user.id,
          original_category: finalCategory,
          original_confidence: finalConfidence,
          secondary_category: tfliteResult?.category ?? null,
          secondary_confidence: tfliteResult?.confidence ?? null,
          status: 'PENDING',
        });

        // Insert classification record
        await supabaseAdmin.from('classifications').insert({
          submission_id: submission.id,
          approach: finalApproach,
          category: finalCategory,
          subcategory: finalSubcategory,
          confidence: finalConfidence,
          model_version: 'gemini-1.5-flash',
          raw_response: geminiResult.rawResponse,
        });

        return new Response(JSON.stringify({
          submissionId: submission.id,
          state: 'DISPUTED',
          category: finalCategory,
          confidence: finalConfidence,
          pointsAwarded: 0,
        }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
      }

      // High confidence: award points
      const pointsForCategory = pointsPerCategory[finalCategory.toLowerCase()] ?? pointsPerCategory['general'] ?? 5;

      // Auto-verify and reward
      if (finalConfidence >= 0.85) {
        state = 'REWARDED';
      } else {
        state = 'VERIFIED';
      }

      const pointsAwarded = state === 'REWARDED' ? pointsForCategory : 0;

      let submission;
      try {
        const { data } = await supabaseAdmin
          .from('submissions')
          .insert({
            user_id: user.id,
            username: profile?.username ?? 'unknown',
            image_url: imageUrl,
            storage_path: storagePath,
            category: finalCategory,
            subcategory: finalSubcategory,
            confidence: finalConfidence,
            primary_approach: finalApproach,
            state: state,
            points_awarded: pointsAwarded,
            idempotency_key: idempotencyKey,
            classified_at: new Date().toISOString(),
          })
          .select('id')
          .single();
        submission = data;
      } catch (insertError: any) {
        if (insertError?.code === '23505') {
          const { data: existing } = await supabaseAdmin
            .from('submissions')
            .select('id, state, category, confidence, points_awarded')
            .eq('idempotency_key', idempotencyKey)
            .single();
          return new Response(JSON.stringify({
            submissionId: existing.id,
            state: existing.state,
            category: existing.category,
            confidence: existing.confidence,
            pointsAwarded: existing.points_awarded,
          }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
        }
        throw insertError;
      }

      // Insert classification record
      await supabaseAdmin.from('classifications').insert({
        submission_id: submission.id,
        approach: finalApproach,
        category: finalCategory,
        subcategory: finalSubcategory,
        confidence: finalConfidence,
        model_version: 'gemini-1.5-flash',
        raw_response: geminiResult.rawResponse,
      });

      // Award points if rewarded
      if (pointsAwarded > 0) {
        await awardPoints(supabaseAdmin, user.id, submission.id, pointsAwarded, 'CLASSIFICATION', idempotencyKey + '_reward');
      }

      // Audit log
      await writeAudit(supabaseAdmin, user.id, 'CLASSIFICATION', 'submission', submission.id, {
        category: finalCategory,
        confidence: finalConfidence,
        approach: finalApproach,
        points: pointsAwarded,
      });

      return new Response(JSON.stringify({
        submissionId: submission.id,
        state: state,
        category: finalCategory,
        subcategory: finalSubcategory,
        confidence: finalConfidence,
        pointsAwarded: pointsAwarded,
      }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
    }

    throw new Error('Unknown action');
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
    });
  }
});

async function classifyWithGemini(imageUrl: string) {
  const prompt = `Analyze this waste image and classify it. Respond in JSON format only:
{"category": "organic|recyclable|hazardous|general", "subcategory": "specific item name", "confidence": 0.0-1.0, "reasoning": "brief explanation"}`;

  const imageResponse = await fetch(imageUrl);
  if (!imageResponse.ok) {
    throw new Error(`Failed to fetch image: ${imageResponse.status}`);
  }
  const imageBuffer = await imageResponse.arrayBuffer();
  const uint8Array = new Uint8Array(imageBuffer);
  let binary = '';
  for (let i = 0; i < uint8Array.length; i++) {
    binary += String.fromCharCode(uint8Array[i]);
  }
  const base64Image = btoa(binary);

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [
          { text: prompt },
          { inline_data: { mime_type: 'image/jpeg', data: base64Image } }
        ]}],
      }),
    }
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(`Gemini API error: ${JSON.stringify(data)}`);
  }

  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';

  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);
      return {
        category: parsed.category ?? 'general',
        subcategory: parsed.subcategory ?? null,
        confidence: Math.min(1.0, Math.max(0.0, Number(parsed.confidence) || 0.5)),
        rawResponse: data,
      };
    }
  } catch { /* fallback */ }

  return { category: 'general', subcategory: null, confidence: 0.3, rawResponse: data };
}

async function awardPoints(admin: any, userId: string, submissionId: string, points: number, type: string, idempotencyKey: string) {
  // Idempotency check
  const { data: existing } = await admin
    .from('rewards')
    .select('id')
    .eq('idempotency_key', idempotencyKey)
    .maybeSingle();

  if (existing) return;

  await admin.from('rewards').insert({
    user_id: userId,
    submission_id: submissionId,
    points: points,
    type: type,
    idempotency_key: idempotencyKey,
  });

  // Update profile points
  await admin.rpc('increment_profile_points', { user_id: userId, amount: points });
}

async function writeAudit(admin: any, actorId: string, eventType: string, targetType: string, targetId: string, details: any) {
  const { data: profile } = await admin.from('profiles').select('role').eq('uid', actorId).single();
  await admin.from('audit_log').insert({
    event_type: eventType,
    actor_id: actorId,
    actor_role: profile?.role ?? 'citizen',
    target_type: targetType,
    target_id: targetId,
    details: details,
  });
}
