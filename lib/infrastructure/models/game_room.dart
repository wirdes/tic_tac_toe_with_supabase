class GameRoom {
  String? roomId;
  final String roomName;
  final String boardType;
  final bool status;
  final String boardColor;
  final String createdBy;
  final int winCondition;

  GameRoom({
    this.roomId,
    required this.roomName,
    required this.boardType,
    required this.status,
    required this.boardColor,
    required this.createdBy,
    required this.winCondition,
  });

  factory GameRoom.fromJson(Map<String, dynamic> json) {
    return GameRoom(
      roomId: json['room_id'] as String,
      roomName: json['room_name'] as String,
      boardType: json['board_type'] as String,
      status: json['status'] as bool,
      boardColor: json['board_color'] as String,
      createdBy: json['created_by'] as String,
      winCondition: json['win_condition'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_name': roomName,
      'board_type': boardType,
      'status': status,
      'board_color': boardColor,
      'created_by': createdBy,
      'win_condition': winCondition,
    };
  }
}
