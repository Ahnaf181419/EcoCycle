import 'jsr:@supabase/functions-js@2/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

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
    const { action, points, idempotencyKey } = body;

    if (action === 'redeem') {
      if (!points || points <= 0) throw new Error('Invalid points amount');

      // Check idempotency
      const { data: existing } = await supabaseAdmin
        .from('rewards')
        .select('id')
        .eq('idempotency_key', idempotencyKey)
        .maybeSingle();
      if (existing) {
        const { data: profile } = await supabaseAdmin
          .from('profiles')
          .select('points, redeemed_points')
          .eq('uid', user.id)
          .single();
        return new Response(JSON.stringify({
          availableBalance: (profile?.points ?? 0) - (profile?.redeemed_points ?? 0),
        }), { headers: { ...corsHeaders(), 'Content-Type': 'application/json' } });
      }

      // Get current balance
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('points, redeemed_points')
        .eq('uid', user.id)
        .single();

      if (!profile) throw new Error('Profile not found');
      const available = profile.points - profile.redeemed_points;
      if (available < points) throw new Error('Insufficient points');

      // Insert redemption reward
      await supabaseAdmin.from('rewards').insert({
        user_id: user.id,
        points: -points,
        type: 'REDEMPTION',
        idempotency_key: idempotencyKey,
      });

      // Update redeemed_points on profile
      await supabaseAdmin
        .from('profiles')
        .update({ redeemed_points: profile.redeemed_points + points })
        .eq('uid', user.id);

      // Audit log
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'REDEMPTION',
        actor_id: user.id,
        actor_role: 'citizen',
        target_type: 'reward',
        target_id: idempotencyKey,
        details: { points, previousRedeemed: profile.redeemed_points },
      });

      return new Response(JSON.stringify({
        availableBalance: available - points,
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
