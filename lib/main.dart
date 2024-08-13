import 'package:flutter/material.dart';
import 'package:tic_tac_toe_with_supabase/core/initial/initial.dart';
import 'package:tic_tac_toe_with_supabase/presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialRequired.initRequireds();
  runApp(const App());
}
