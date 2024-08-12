import 'package:flutter/material.dart';

enum Paths {
  welcome('/home', SizedBox()),
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
