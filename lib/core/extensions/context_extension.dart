import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';

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

  void go(Paths path, {Object? extra}) => router.go(path.path, extra: extra);
  void pop<T extends Object?>([T? result]) => router.pop(result);
  SupabaseClient get _supabase => Supabase.instance.client;
  GoTrueClient get auth => _supabase.auth;
  SupabaseQueryBuilder get profile => _supabase.from('profiles');
  SupabaseQueryBuilder get games => _supabase.from('game_rooms');
  SupabaseQueryBuilder get gameMoves => _supabase.from('game_moves');
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
