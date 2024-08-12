import 'package:go_router/go_router.dart';
import 'package:tic_tac_toe_with_supabase/core/database/database.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';

abstract final class Routes {
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final routerConfig = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation:
        Database().hasName() ? Paths.gameList.path : Paths.welcome.path,
    routes: Paths.values
        .map(
          (path) => GoRoute(
            name: path.name,
            path: path.path,
            builder: (context, state) => path.page,
          ),
        )
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
