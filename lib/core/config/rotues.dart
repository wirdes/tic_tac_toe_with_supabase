import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/presentation/screens/screens.dart';

abstract final class Routes {
  static final routerConfig = GoRouter(
    initialLocation: Supabase.instance.client.auth.currentUser != null
        ? Paths.gameList.path
        : Paths.welcome.path,
    routes: [
      for (var path in Paths.values)
        if (path == Paths.game)
          GoRoute(
            name: Paths.game.name,
            path: "${Paths.game.path}/:gameId",
            builder: (context, state) {
              final gameId = state.pathParameters['gameId']!;
              return GameScreen(gameId: gameId);
            },
          )
        else
          GoRoute(
            name: path.name,
            path: path.path,
            builder: (context, state) => path.page,
          ),
    ],
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
          child:
              Text(state.path.toString(), style: context.textTheme.labelLarge),
        ),
      );
    },
  );
}
