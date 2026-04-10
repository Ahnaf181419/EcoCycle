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
    const { action, targetUserId } = body;

    if (action === 'follow') {
      if (!targetUserId) throw new Error('Missing targetUserId');
      if (targetUserId === user.id) throw new Error('Cannot follow yourself');

      // Check if already following
      const { data: existing } = await supabaseAdmin
        .from('follows')
        .select('follower_id')
        .eq('follower_id', user.id)
        .eq('followee_id', targetUserId)
        .maybeSingle();

      if (existing) {
        return new Response(JSON.stringify({ success: true, message: 'Already following' }), {
          headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        });
      }

      // Insert follow
      await supabaseAdmin.from('follows').insert({
        follower_id: user.id,
        followee_id: targetUserId,
      });

      // Atomically increment counters
      await supabaseAdmin.rpc('atomic_increment_follow', {
        p_follower_id: user.id,
        p_followee_id: targetUserId,
      });

      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      });
    }

    if (action === 'unfollow') {
      if (!targetUserId) throw new Error('Missing targetUserId');

      // Delete follow
      const { error: deleteError } = await supabaseAdmin
        .from('follows')
        .delete()
        .eq('follower_id', user.id)
        .eq('followee_id', targetUserId);

      if (deleteError) throw deleteError;

      // Atomically decrement counters
      await supabaseAdmin.rpc('atomic_decrement_follow', {
        p_follower_id: user.id,
        p_followee_id: targetUserId,
      });

      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      });
    }

    throw new Error('Unknown action');
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
    });
  }
});
