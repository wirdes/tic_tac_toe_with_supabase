import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';

class GameMove {
  String? moveId;
  String? roomId;
  String? playerId;
  int row;
  int col;
  int moveNumber;
  DateTime movedAt;
  String? data;

  GameMove({
    this.moveId,
    this.roomId,
    this.playerId,
    required this.row,
    required this.col,
    required this.moveNumber,
    required this.movedAt,
    this.data,
  });

  factory GameMove.fromJson(Map<String, dynamic> json) {
    return GameMove(
      moveId: json['move_id'] as String,
      roomId: json['room_id'] as String,
      playerId: json['player_id'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      moveNumber: json['move_number'] as int,
      movedAt: DateTime.parse(json['moved_at'] as String),
      data: json['data'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'player_id': playerId,
      'row': row,
      'col': col,
      'move_number': moveNumber,
      'moved_at': movedAt.toIso8601String(),
      'data': data,
    };
  }

  Future<GameMove?> insert(BuildContext context) async {
    try {
      final returnData = await context.insertGameMove(this);
      final moves = returnData ?? [];
      moves.sort((a, b) => b.moveNumber.compareTo(a.moveNumber));
      return moves.first;
    } catch (e) {
      context.showErrorSnackBar(e.toString());
      return null;
    }
  }
}
