import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/config/config.dart';

class InitialRequired {
  static Future<void> initRequireds() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.key,
      debug: false,
    );
  }
}
