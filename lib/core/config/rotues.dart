import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';

abstract final class Routes {
  static final routerConfig = GoRouter(
    initialLocation: Supabase.instance.client.auth.currentUser != null
        ? Paths.gameList.path
        : Paths.welcome.path,
    routes: Paths.values
        .map((path) => GoRoute(
              name: path.name,
              path: path.path,
              builder: (context, state) => path.page,
            ))
        .toList(),
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('404 - Page not found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.go(Paths.gameList.path),
          ),
        ),
        body: Center(
          child: Text('Page not found ${state.fullPath}',
              style: context.textTheme.labelLarge),
        ),
      );
    },
  );
}
