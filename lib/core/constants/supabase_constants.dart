import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConstants {
  SupabaseConstants._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Call once at app startup — fails fast if the build forgot to pass
  /// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
  static void assertConfigured() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase is not configured. Pass --dart-define=SUPABASE_URL=... '
        'and --dart-define=SUPABASE_ANON_KEY=... at build time.',
      );
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}

class SupabaseTables {
  SupabaseTables._();

  static const String profiles = 'profiles';
  static const String submissions = 'submissions';
  static const String classifications = 'classifications';
  static const String disputes = 'disputes';
  static const String rewards = 'rewards';
  static const String follows = 'follows';
  static const String auditLog = 'audit_log';
  static const String config = 'config';
}

class SupabaseStorage {
  SupabaseStorage._();

  static const String submissionsBucket = 'submissions';
}

class EdgeFunctionNames {
  EdgeFunctionNames._();

  static const String classify = 'classify';
  static const String rewards = 'rewards';
  static const String disputes = 'disputes';
  static const String social = 'social';
  static const String admin = 'admin';
}
