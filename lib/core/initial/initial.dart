import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/config/config.dart';
import 'package:tic_tac_toe_with_supabase/core/database/database.dart';

class InitialRequired {
  static Future<void> initRequireds() async {
    await Hive.initFlutter('orman');
    await Database().init();
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.key,
      debug: false,
    );
  }
}
