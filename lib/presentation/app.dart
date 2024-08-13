import 'package:flutter/material.dart';
import 'package:tic_tac_toe_with_supabase/core/config/config.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
        useMaterial3: true,
        colorSchemeSeed: const Color.fromRGBO(188, 0, 74, 1.0),
      ),
      routerConfig: Routes.routerConfig,
    );
  }
}
