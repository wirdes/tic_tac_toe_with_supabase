import 'dart:async';
import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/manager/game_manager.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/models.dart';

class Board extends StatefulWidget {
  final GameManager gameManager;
  const Board({super.key, required this.gameManager});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late final StreamSubscription<List<Map<String, dynamic>>> _gameMove;
  late GameManager gameManager;
  String _status = '';
  bool isLoading = false;
  GameState gameState = GameState.continueGame;

  void _showEndGameDialog(GameState gameState, BuildContext context) {
    setState(() => isLoading = true);
    String message = '';
    if (gameState == GameState.winPlayer1) {
      message = '${gameManager.player1Name} win';
    } else if (gameState == GameState.winPlayer2) {
      message = '${gameManager.player2Name} win';
    } else {
      message = 'Draw';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game End'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                if (gameState != GameState.draw) {
                  await context.setStatusRoom(roomId: gameManager.roomId);

                  context.go(Paths.gameList);
                } else {
                  await gameManager.resetGame(context);
                  setState(() => isLoading = false);
                  Navigator.of(context).pop();
                }
              } catch (e) {
                context.showErrorSnackBar(e.toString());
              }
            },
            child: Text(gameState == GameState.draw ? 'Restart' : 'Close'),
          ),
        ],
      ),
    );
  }

  void getBoard() async {
    setState(() => isLoading = true);
    final list = await context.getAllGameMoves(gameManager.roomId) ?? [];
    for (var e in list) {
      gameManager.insertMove(e);
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    gameManager = widget.gameManager;
    getBoard();
    _gameMove = context.onChangesGameMoves(
      gameManager.roomId,
      (data) => onChangesMove(data, context),
    );
    setStatus(status: 'initState');
  }

  void onChangesMove(List<Map<String, dynamic>> data, BuildContext context) {
    if (data.isEmpty) return;
    try {
      final moves = data.map((e) => GameMove.fromJson(e)).toList();
      moves.sort((a, b) => b.moveNumber.compareTo(a.moveNumber));

      final move = moves.first;
      gameManager.insertMove(move);
      if (gameManager.checkWinner() != gameState) {
        gameState = gameManager.checkWinner();
        switch (gameState) {
          case GameState.winPlayer1:
          case GameState.winPlayer2:
          case GameState.draw:
            _showEndGameDialog(gameState, context);
            break;
          case GameState.continueGame:
            break;
        }
      }

      setStatus();
    } catch (e) {
      context.showErrorSnackBar(e.toString());
    }
  }

  @override
  void dispose() {
    _gameMove.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        body: Material(
          color: gameManager.boardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _status,
                style: context.textTheme.titleLarge?.apply(
                  color: gameManager.boardColor.getTextColor(),
                ),
              ),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: gameManager.boardColor,
                  child: Stack(
                    children: [
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gameManager.boardSize,
                        ),
                        itemBuilder: _buildGridCell,
                        itemCount:
                            gameManager.boardSize * gameManager.boardSize,
                      ),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCell(BuildContext context, int index) {
    int row = index ~/ gameManager.boardSize;
    int col = index % gameManager.boardSize;
    return GestureDetector(
      onTap: () => _onCellTap(row, col, context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: gameManager.boardColor.getTextColor()),
        ),
        child: Center(
          child: Text(gameManager.board[row][col],
              style: context.textTheme.headlineMedium
                  ?.apply(color: gameManager.boardColor.getTextColor())),
        ),
      ),
    );
  }

  void setStatus({String? status}) {
    if (status != null) {
      debugPrint('${gameManager.lastMoves} $status');
    }
    setState(() {
      _status = gameManager.currentPlayerId == context.userId
          ? "Your Turn"
          : "Opponent's Turn";
    });
  }

  void _onCellTap(int row, int col, BuildContext context) async {
    if (context.userId != gameManager.currentPlayerId) {
      context.showErrorSnackBar('Not your turn');
      return;
    }
    await gameManager.makeMove(row, col, context);
  }
}
