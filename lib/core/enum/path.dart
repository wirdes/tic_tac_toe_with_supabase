import 'package:tic_tac_toe_with_supabase/presentation/screens/screens.dart';

enum Paths {
  welcome('/home', WelcomeScreen()),
  gameList('/game-list', SizedBox()),
  createGame('/create-game', SizedBox()),
  game('/game-screen', SizedBox()),
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
