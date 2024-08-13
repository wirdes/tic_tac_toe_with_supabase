import 'dart:async';
import 'dart:core';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/models.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);
  bool get alwaysUse24HourFormat => MediaQuery.alwaysUse24HourFormatOf(this);
  double get width => mediaQuerySize.width;
  double get height => mediaQuerySize.height;
  ColorScheme get colorScheme => theme.colorScheme;
  //Router
  GoRouter get router => GoRouter.of(this);
  Future<T?> push<T extends Object?>(Paths path,
      {Object? extra, String? query}) {
    return router.push("${path.path}${query ?? ''}", extra: extra);
  }

  void go(Paths path, {Object? extra, String? query}) =>
      router.go("${path.path}${query ?? ''}", extra: extra);
  void pop<T extends Object?>([T? result]) => router.pop(result);
  SupabaseClient get _supabase => Supabase.instance.client;
  GoTrueClient get auth => _supabase.auth;
  SupabaseQueryBuilder get _profile => _supabase.from('profiles');
  Future<Profile?> userProfile(String playerId) async {
    try {
      final res = await _profile.select().eq('id', playerId);
      if (res.isEmpty) return null;
      return Profile.fromJson(res.first);
    } catch (e) {
      return null;
    }
  }

  SupabaseQueryBuilder get _games => _supabase.from('game_rooms');
  SupabaseQueryBuilder get _gameMoves => _supabase.from('game_moves');
  SupabaseQueryBuilder get playerRoom => _supabase.from('player_room');
  Future<GameRoom?> getGameRoom(String roomId) async {
    final res = await _games.select().eq('status', true).eq('room_id', roomId);
    if (res.isEmpty) return null;
    final gameRoom = GameRoom.fromJson(res.first);
    return gameRoom;
  }

  Future<void> setStatusRoom({
    required String roomId,
    bool status = false,
  }) async {
    await _games.update({'status': status}).eq('room_id', roomId);
  }

  StreamSubscription<List<Map<String, dynamic>>> onChangesRooms(
    void Function(List<Map<String, dynamic>>)? onData,
  ) {
    return _games.stream(primaryKey: ['id']).eq('status', true).listen(onData);
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> getRooms() {
    return _games.select().eq('status', true);
  }

  Future<GameRoom?> insertGameRoom(GameRoom gameRoom) async {
    final res = await _games.insert(gameRoom.toJson()).select();
    if (res.isEmpty) return null;
    return GameRoom.fromJson(res.first);
  }

  Future<void> resetGame(String roomId) async {
    await _gameMoves.delete().eq('room_id', roomId);
  }

  Future<List<GameMove>?> insertGameMove(GameMove gameMove) async {
    final res = await _gameMoves.insert(gameMove.toJson()).select();
    if (res.isEmpty) return null;
    return res.map((e) => GameMove.fromJson(e)).toList();
  }

  Future<List<GameMove>?> getAllGameMoves(String roomId) async {
    final res = await _gameMoves.select().eq('room_id', roomId);
    if (res.isEmpty) return null;
    final moves = res.map((e) => GameMove.fromJson(e)).toList();
    moves.sort((a, b) => b.moveNumber.compareTo(a.moveNumber));
    return moves;
  }

  StreamSubscription<List<Map<String, dynamic>>> onChangesGameMoves(
    String roomId,
    void Function(List<Map<String, dynamic>>)? onData,
  ) {
    return _gameMoves.stream(primaryKey: ['id']).eq('room_id', roomId).listen(onData);
  }

  String? get userId => auth.currentUser?.id;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
    String content, {
    Duration duration = const Duration(seconds: 1),
  }) =>
      mounted
          ? ScaffoldMessenger.of(this).showSnackBar(SnackBar(
              content: Text(content),
              duration: duration,
            ))
          : null;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showErrorSnackBar(
    String content, {
    Duration duration = const Duration(seconds: 1),
  }) =>
      mounted
          ? ScaffoldMessenger.of(this).showSnackBar(
              SnackBar(
                content: Text(
                  content,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: theme.colorScheme.error,
                duration: duration,
              ),
            )
          : null;
}
