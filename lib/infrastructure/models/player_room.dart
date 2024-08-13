// CREATE TABLE player_room (
//     room_id UUID REFERENCES game_rooms(room_id),
//     player_id UUID REFERENCES users(id),
//     joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
//     PRIMARY KEY (player_id, room_id)
// );

class PlayerRoom {
  final String roomId;
  final String playerId;
  final DateTime joinedAt;

  PlayerRoom({
    required this.roomId,
    required this.playerId,
    required this.joinedAt,
  });

  factory PlayerRoom.fromJson(Map<String, dynamic> json) {
    return PlayerRoom(
      roomId: json['room_id'],
      playerId: json['player_id'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'player_id': playerId,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
