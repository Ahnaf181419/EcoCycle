// This file runs in Deno (Supabase Edge Functions). VS Code's default TS
// server can't resolve jsr: specifiers or the Deno global, so we silence
// those IDE-only diagnostics. The Supabase CLI type-checks this correctly
// at deploy time.
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

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
  });
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
    const { action } = body;

    // ---------------------------------------------------------------------
    // Self-service: users deleting their OWN account.
    // This action does NOT require admin role — the caller can only delete
    // the account they're authenticated as. We still allow admins to delete
    // any user by passing a different `userId`.
    // ---------------------------------------------------------------------
    if (action === 'deleteAccount') {
      const targetId: string = body.userId ?? user.id;

      // Non-admins may only delete themselves.
      if (targetId !== user.id) {
        const { data: callerProfile } = await supabaseAdmin
          .from('profiles')
          .select('role')
          .eq('uid', user.id)
          .single();
        if (!callerProfile || callerProfile.role !== 'admin') {
          throw new Error('Forbidden: can only delete your own account');
        }
      }

      // 1. Audit log BEFORE deletion so we keep a record even if the caller
      //    is deleting themselves (audit_log has no FKs to profiles).
      await supabaseAdmin.from('audit_log').insert({
        event_type: 'ACCOUNT_DELETE',
        actor_id: user.id,
        actor_role: targetId === user.id ? 'self' : 'admin',
        target_type: 'profile',
        target_id: targetId,
        details: {},
      });

      // 2. Best-effort wipe of storage objects. The bucket is laid out as
      //    `submissions/<userId>/<fileName>`; storage has no DB cascade.
      try {
        const { data: files } = await supabaseAdmin
          .storage
          .from('submissions')
          .list(targetId, { limit: 1000 });
        if (files && files.length > 0) {
          const paths = files.map((f: { name: string }) => `${targetId}/${f.name}`);
          await supabaseAdmin.storage.from('submissions').remove(paths);
        }
      } catch (_storageErr) {
        // Don't block account deletion on stray files.
      }

      // 3. Drop the auth user. This cascades to profiles via
      //    `profiles.uid REFERENCES auth.users(id) ON DELETE CASCADE`,
      //    which in turn cascades to submissions, classifications, disputes,
      //    rewards, and follows (all declared ON DELETE CASCADE in schema.sql).
      const { error: authDeleteError } =
        await supabaseAdmin.auth.admin.deleteUser(targetId);
      if (authDeleteError) throw authDeleteError;

      return jsonResponse({ success: true });
    }

    // ---------------------------------------------------------------------
    // All actions below require the ADMIN role.
    // ---------------------------------------------------------------------
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('uid', user.id)
      .single();

    if (!profile || profile.role !== 'admin') {
      throw new Error('Insufficient permissions: admin role required');
    }

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

      return jsonResponse({ success: true });
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

      return jsonResponse({ success: true, config: mergedConfig });
    }

    throw new Error('Unknown action');
  } catch (error) {
    return jsonResponse({ error: (error as Error).message }, 400);
  }
});
