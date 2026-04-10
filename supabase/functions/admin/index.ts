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

    // Verify admin role
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('uid', user.id)
      .single();

    if (!profile || profile.role !== 'admin') {
      throw new Error('Insufficient permissions: admin role required');
    }

    const body = await req.json();
    const { action } = body;

    if (action === 'updateRole') {
      const { targetUserId, newRole } = body;
      if (!targetUserId || !newRole) throw new Error('Missing targetUserId or newRole');
      if (!['citizen', 'moderator', 'admin'].includes(newRole)) {
        throw new Error('Invalid role');
      }

      await supabaseAdmin
        .from('profiles')
        .update({ role: newRole })
        .eq('uid', targetUserId);

      // Audit log
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'ROLE_UPDATE',
        actor_id: user.id,
        actor_role: 'admin',
        target_type: 'profile',
        target_id: targetUserId,
        details: { newRole },
      });

      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
      });
    }

    if (action === 'updateConfig') {
      const configKeys = ['confidenceThreshold', 'pointsPerCategory', 'duplicateTimeWindowHours', 'maxDailySubmissions', 'leaderboardCacheSeconds'];
      const updates: any = {};

      for (const key of configKeys) {
        if (body[key] !== undefined) {
          updates[key] = body[key];
        }
      }

      if (Object.keys(updates).length === 0) {
        throw new Error('No valid config keys provided');
      }

      // Get current config and merge
      const { data: currentConfig } = await supabaseAdmin
        .from('config')
        .select('value')
        .eq('key', 'system')
        .single();

      const mergedConfig = { ...(currentConfig?.value ?? {}), ...updates };

      await supabaseAdmin
        .from('config')
        .update({ value: mergedConfig })
        .eq('key', 'system');

      // Audit log
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'CONFIG_UPDATE',
        actor_id: user.id,
        actor_role: 'admin',
        target_type: 'config',
        target_id: 'system',
        details: updates,
      });

      return new Response(JSON.stringify({ success: true, config: mergedConfig }), {
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
