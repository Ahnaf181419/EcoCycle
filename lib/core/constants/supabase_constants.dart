import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConstants {
  SupabaseConstants._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jqczqdsogvagttrkzucu.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxY3pxZHNvZ3ZhZ3R0cmt6dWN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4NDAxODgsImV4cCI6MjA5MTQxNjE4OH0.C6IIVZ6pRKurK4f_MHLelskKyyGy4QQE1Llhl0FAUdM',
  );

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
