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
  final Map<String, String> _cache = {};

  @override
  void initState() {
    super.initState();
    if (widget.gameId == null) {
      throw Exception('Game Id is required');
    }
    getGameRoom();

    _player = context.playerRoom
        .stream(primaryKey: ['id'])
        .eq('room_id', widget.gameId!)
        .listen(onChangesPlayer);
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
          const SizedBox(height: 16),
          Text('Players', style: style),
          SizedBox(
            height: 120,
            child: Column(children: [
              for (var player in players)
                ListTile(
                  title: Text(
                      '${_cache[player.playerId]!} (${context.userId == player.playerId ? 'You' : 'Opponent'})',
                      style: style?.apply(
                        fontSizeDelta: -3,
                      )),
                )
            ]),
          ),
          if (players.length < 2)
            Expanded(
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
              child: Board(
                  gameManager: GameManager(
                boardSize: gameRoom!.boardType.size,
                winLengths: gameRoom!.winCondition,
                boardColor: gameRoom!.boardColor.fromHex(),
                player1: {players[0].playerId: _cache[players[0].playerId]!},
                player2: {
                  players[1].playerId: _cache[players[1].playerId]!,
                },
                roomId: gameRoom!.roomId!,
              )),
            ),
        ],
      ),
    );
  }

  void onChangesPlayer(List<Map<String, dynamic>> data) async {
    final players = data.map((e) => PlayerRoom.fromJson(e)).toList();
    players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
    this.players = players;
    setState(() => isLoaded = false);
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

  Future<String> getPlayerName(String playerId) async {
    final data = await context.userProfile(playerId);
    final playerName = data?.username ?? 'Unknown';
    _cache[playerId] = playerName;
    return playerName;
  }

  void getGameRoom() async {
    try {
      final game = await context.getGameRoom(widget.gameId!);
      gameRoom = game;
      if (mounted && gameRoom != null) {
        final list =
            await context.playerRoom.select().eq('room_id', gameRoom!.roomId!);
        final players = list.map((e) => PlayerRoom.fromJson(e)).toList();
        players.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
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
}


// UPDATE game_rooms SET status = false WHERE 1 = 1;
