import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/manager/game_manager.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/game_move.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/game_room.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/player_room.dart';
import 'package:tic_tac_toe_with_supabase/presentation/screens/game/play/components/board.dart';

class GameScreen extends StatefulWidget {
  final String? gameId;
  const GameScreen({super.key, this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isLoaded = false;

  late final StreamSubscription<List<Map<String, dynamic>>> _player;
  GameRoom? gameRoom;
  List<GameMove> gameMoves = [];
  List<PlayerRoom> players = [];
  final Map<String, String> playerNames = {};

  @override
  void initState() {
    super.initState();
    if (widget.gameId == null) {
      throw Exception('Game Id is required');
    }
    getGameRoom();

    _player = context.onChangesPlayerRoom(widget.gameId!, onChangesPlayer);
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (gameRoom == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game'),
        ),
        body: const Center(
          child: Text('Game not found'),
        ),
      );
    }
    final style = context.textTheme.titleLarge?.apply(
      color: gameRoom!.boardColor.fromHex().getTextColor(),
    );
    return Scaffold(
      backgroundColor: gameRoom!.boardColor.fromHex(),
      appBar: AppBar(
        title: Text('Game ${gameRoom!.roomName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Paths.gameList),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text('Players', style: style),
                Column(children: [
                  for (var player in players)
                    ListTile(
                      leading: gameRoom!.createdBy == player.playerId
                          ? const Icon(Icons.star, color: Colors.yellow)
                          : null,
                      title: Text(
                        '${playerNames[player.playerId]!} ${context.userId == player.playerId ? '(You)' : ''} ',
                        style: style?.apply(
                          fontSizeDelta: -3,
                          fontWeightDelta:
                              context.userId == player.playerId ? 2 : 0,
                        ),
                      ),
                      subtitle: Text(
                        gameRoom!.createdBy == player.playerId ? 'X' : 'O',
                        style: context.textTheme.titleSmall?.apply(
                          color: gameRoom!.boardColor.fromHex().getTextColor(),
                        ),
                      ),
                    ),
                ]),
              ],
            ),
          ),
          if (players.length < 2)
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Waiting for player to join', style: style),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                        color: gameRoom!.boardColor.fromHex().getTextColor()),
                  ],
                ))
          else
            Expanded(
              flex: 3,
              child: Board(
                  gameManager: GameManager(
                boardSize: gameRoom!.boardType.size,
                winLengths: gameRoom!.winCondition,
                boardColor: gameRoom!.boardColor.fromHex(),
                player1: {
                  players[0].playerId: playerNames[players[0].playerId]!
                },
                player2: {
                  players[1].playerId: playerNames[players[1].playerId]!,
                },
                roomId: gameRoom!.roomId!,
              )),
            ),
        ],
      ),
    );
  }

  void onChangesPlayer(List<Map<String, dynamic>> data) async {
    setState(() => isLoaded = false);
    final players = data.map((e) => PlayerRoom.fromJson(e)).toList();
    players.sort((a, b) => gameRoom?.createdBy == a.playerId ? -1 : 1);
    this.players = players;
    for (var element in players) {
      await getPlayerName(element.playerId);
    }
    setState(() => isLoaded = true);
  }

  @override
  void dispose() {
    _player.cancel();
    super.dispose();
  }

  void getGameRoom() async {
    try {
      final game = await context.getGameRoom(widget.gameId!);
      gameRoom = game;
      if (mounted && gameRoom != null) {
        final players =
            await context.getPlayerRoom(gameRoom!.roomId!) ?? <PlayerRoom>[];
        players.sort((a, b) => gameRoom!.createdBy == a.playerId ? -1 : 1);
        this.players = players;
      }

      for (var element in players) {
        await getPlayerName(element.playerId);
      }

      isLoaded = true;

      setState(() {});
    } on PostgrestException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  Future<String> getPlayerName(String playerId) async {
    final data = await context.userProfile(playerId);
    final playerName = data?.username ?? 'Unknown';
    playerNames[playerId] = playerName;
    return playerName;
  }
}
