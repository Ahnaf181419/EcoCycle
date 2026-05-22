// Runs in Deno (Supabase Edge Functions). VS Code's default TS server can't
// resolve jsr: specifiers or the Deno global, so silence IDE-only diagnostics.
// @ts-ignore - jsr specifier resolved by Deno at runtime
import 'jsr:@supabase/functions-js@2/edge-runtime.d.ts';
// @ts-ignore - jsr specifier resolved by Deno at runtime
import { createClient } from 'jsr:@supabase/supabase-js@2';

declare const Deno: {
  env: { get(key: string): string | undefined };
  serve(handler: (req: Request) => Response | Promise<Response>): void;
};

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

    // Verify moderator/admin role
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('uid', user.id)
      .single();

    if (!profile || !['moderator', 'admin'].includes(profile.role)) {
      throw new Error('Insufficient permissions');
    }

    const body = await req.json();
    const { action, disputeId, resolution, category, note } = body;

    if (action === 'resolve') {
      if (!disputeId || !resolution) throw new Error('Missing required fields');

      // Get dispute
      const { data: dispute } = await supabaseAdmin
        .from('disputes')
        .select('*, submissions(*)')
        .eq('id', disputeId)
        .single();

      if (!dispute) throw new Error('Dispute not found');

      // State transition guard — only PENDING disputes can be resolved
      if (dispute.status !== 'PENDING') {
        throw new Error('Dispute is not in PENDING state');
      }

      // Update dispute
      const disputeUpdate: any = {
        status: resolution === 'approve' ? 'APPROVED' : resolution === 'override' ? 'OVERRIDDEN' : 'REJECTED',
        resolved_by: user.id,
        resolution: resolution,
        resolution_note: note ?? null,
        resolved_at: new Date().toISOString(),
      };

      if (category) {
        disputeUpdate.resolved_category = category;
      }

      await supabaseAdmin
        .from('disputes')
        .update(disputeUpdate)
        .eq('id', disputeId);

      // Update submission state
      const submissionState = resolution === 'approve' ? 'REWARDED' : resolution === 'override' ? 'VERIFIED' : 'REJECTED';

      const submissionUpdate: any = {
        state: submissionState,
        updated_at: new Date().toISOString(),
      };

      if (category && resolution === 'override') {
        submissionUpdate.category = category;
      }

      // Award points on approval
      if (resolution === 'approve') {
        const { data: configData } = await supabaseAdmin
          .from('config')
          .select('value')
          .eq('key', 'system')
          .single();
        const config = configData?.value ?? {};
        const pointsPerCategory = config.pointsPerCategory ?? { organic: 10, recyclable: 15, hazardous: 20, general: 5 };
        const cat = (dispute.submissions?.category ?? 'general').toLowerCase();
        const pts = pointsPerCategory[cat] ?? pointsPerCategory['general'] ?? 5;
        submissionUpdate.points_awarded = pts;

        // Create reward (with idempotency via UNIQUE constraint on idempotency_key)
        await supabaseAdmin.from('rewards').insert({
          user_id: dispute.submitter_id,
          submission_id: dispute.submission_id,
          points: pts,
          type: 'CLASSIFICATION',
          idempotency_key: `dispute_${disputeId}_reward`,
        });

        // Atomically increment profile points via RPC
        await supabaseAdmin.rpc('increment_profile_points', { user_id: dispute.submitter_id, amount: pts });

        // Atomically increment correct_count via RPC
        await supabaseAdmin.rpc('increment_correct_count', { p_user_id: dispute.submitter_id });
      }

      await supabaseAdmin
        .from('submissions')
        .update(submissionUpdate)
        .eq('id', dispute.submission_id);

      // Audit log
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'DISPUTE_RESOLUTION',
        actor_id: user.id,
        actor_role: profile.role,
        target_type: 'dispute',
        target_id: disputeId,
        details: { resolution, category, note },
      });

      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      });
    }

    throw new Error('Unknown action');
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 400,
      headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
    });
  }
});
