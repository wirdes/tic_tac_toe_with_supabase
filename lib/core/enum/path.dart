import 'package:tic_tac_toe_with_supabase/presentation/screens/screens.dart';

enum Paths {
  welcome('/home', WelcomeScreen()),
  gameList('/game-list', GameListScreen()),
  createGame('/create-game', GameCreate()),
  game('/game-screen', GameScreen()),
  ;

  final String path;
  final Widget page;

  const Paths(this.path, this.page);

  @override
  String toString() {
    return path;
  }

  String get name => path.split('/').last;
}
