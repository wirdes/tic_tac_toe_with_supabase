import 'dart:async';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/game_room.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/player_room.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  late final StreamSubscription<List<Map<String, dynamic>>> _subscription;
  List<GameRoom> gameRooms = [];
  Map<String, String> userNames = {};

  void getGameRooms() async {
    try {
      final data = await context.getRooms();
      gameRooms = data.map((e) => GameRoom.fromJson(e)).toList();
      setState(() {});
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getGameRooms();
    _subscription = context.onChangesRooms(onChanges);
  }

  @override
  Widget build(BuildContext context) {
    getGameRooms();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game List'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await context.push(Paths.createGame);
              getGameRooms();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: ListView.builder(
          itemCount: gameRooms.length,
          itemBuilder: (context, index) {
            final gameRoom = gameRooms[index];
            final color = gameRoom.boardColor.fromHex();
            final TextStyle? titleStyle = context.textTheme.titleLarge
                ?.apply(color: color.getTextColor());
            final TextStyle? subtitleStyle = context.textTheme.titleSmall
                ?.apply(color: color.getTextColor());
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: ListTile(
                  key: ValueKey(gameRoom.roomId),
                  title: Text(gameRoom.roomName, style: titleStyle),
                  onTap: () async {
                    final roomPlayers = (await context.playerRoom
                            .select()
                            .eq('room_id', gameRoom.roomId!))
                        .map((e) => PlayerRoom.fromJson(e))
                        .toList();

                    if (context.mounted && roomPlayers.length == 2) {
                      final iExist = roomPlayers.where(
                          (element) => element.playerId == context.userId);
                      if (iExist.isEmpty) {
                        context.showErrorSnackBar('Room is full');
                        return;
                      } else {
                        context.push(Paths.game, query: '/${gameRoom.roomId}');
                        return;
                      }
                    }
                    await context.playerRoom.upsert(PlayerRoom(
                        roomId: gameRoom.roomId!,
                        playerId: context.userId!,
                        joinedAt: DateTime.now()));
                    context.push(Paths.game, query: '/${gameRoom.roomId}');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: color,
                  subtitle: Text(
                    'Board: ${gameRoom.boardType} - Win Condition: ${gameRoom.winCondition}',
                    style: subtitleStyle,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded,
                      color: color.getTextColor()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void onChanges(data) => setState(() {});

  @override
  void activate() {
    super.activate();
    getGameRooms();
    _subscription = context.onChangesRooms(onChanges);
  }

  @override
  void deactivate() {
    super.deactivate();
    _subscription.cancel();
  }
}
