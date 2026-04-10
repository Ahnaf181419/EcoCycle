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
      if (!idempotencyKey) throw new Error('Missing idempotencyKey');

      // Atomically redeem points via SQL function (handles race conditions)
      const { data: result, error: rpcError } = await supabaseAdmin
        .rpc('atomic_redeem_points', {
          p_user_id: user.id,
          p_points: points,
          p_idempotency_key: idempotencyKey,
        });

      if (rpcError) throw rpcError;
      if (result?.error) throw new Error(result.error);

      // Get user role for audit
      const { data: profile } = await supabaseAdmin
        .from('profiles')
        .select('role')
        .eq('uid', user.id)
        .single();

      // Audit log
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'REDEMPTION',
        actor_id: user.id,
        actor_role: profile?.role ?? 'citizen',
        target_type: 'reward',
        target_id: idempotencyKey,
        details: { points },
      });

      return new Response(JSON.stringify({
        availableBalance: result?.availableBalance ?? 0,
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
