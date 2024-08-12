class Env {
  static String get supabaseUrl => const String.fromEnvironment('URL');
  static String get key => const String.fromEnvironment('API_KEY');
}
