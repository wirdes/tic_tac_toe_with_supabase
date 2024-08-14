import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/models.dart';

enum GameState {
  draw,
  winPlayer1,
  winPlayer2,
  continueGame,
}

class GameManager {
  final int boardSize;
  final int winLengths;
  late List<List<String>> board;
  final Map<String, String> player1;
  final Map<String, String> player2;
  final Color boardColor;
  final String roomId;
  GameMove? lastMoves;

  GameManager({
    required this.boardSize,
    required this.winLengths,
    required this.boardColor,
    required this.player1,
    required this.player2,
    required this.roomId,
  }) {
    board = List.generate(boardSize, (_) => List.filled(boardSize, ''));
  }
  String get player1Name => player1.values.first;
  String get player2Name => player2.values.first;
  String get player1Id => player1.keys.first;
  String get player2Id => player2.keys.first;

  String get lastId => lastMoves?.playerId ?? player2Id;

  String get currentId => lastId == player1Id ? player2Id : player1Id;
  String get currentName => currentId == player1Id ? player1Name : player2Name;
  String get currentSymbol => currentId == player1Id ? 'X' : 'O';

  Future<void> makeMove(int row, int col, BuildContext context) async {
    if (board[row][col] != '') {
      context.showErrorSnackBar('Cell is not empty');
      return;
    }
    final data = currentSymbol;
    final lastMove = await GameMove(
            roomId: roomId,
            row: row,
            col: col,
            playerId: currentId,
            moveNumber:
                lastMoves?.moveNumber != null ? lastMoves!.moveNumber + 1 : 1,
            movedAt: DateTime.now(),
            data: data)
        .insert(context);
    if (lastMove == null) {
      context.showErrorSnackBar('Failed to insert move');
    }
  }

  GameState checkWinner() {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j <= boardSize - winLengths; j++) {
        final dummy = List.generate(winLengths, (k) => board[i][j + k]);
        final first = dummy.first;
        if (dummy.every((cell) => cell == first && first != '')) {
          return first == 'X' ? GameState.winPlayer1 : GameState.winPlayer2;
        }
      }
    }
    for (int i = 0; i <= boardSize - winLengths; i++) {
      for (int j = 0; j < boardSize; j++) {
        final dummy = List.generate(winLengths, (k) => board[i + k][j]);
        final first = dummy.first;
        if (dummy.every((cell) => cell == first && first != '')) {
          return first == 'X' ? GameState.winPlayer1 : GameState.winPlayer2;
        }
      }
    }

    for (int i = 0; i <= boardSize - winLengths; i++) {
      for (int j = 0; j <= boardSize - winLengths; j++) {
        final dummy = List.generate(winLengths, (k) => board[i + k][j + k]);
        final first = dummy.first;
        if (dummy.every((cell) => cell == first && first != '')) {
          return first == 'X' ? GameState.winPlayer1 : GameState.winPlayer2;
        }
      }
    }
    for (int i = 0; i <= boardSize - winLengths; i++) {
      for (int j = winLengths - 1; j < boardSize; j++) {
        final dummy = List.generate(winLengths, (k) => board[i + k][j - k]);
        final first = dummy.first;

        if (dummy.every((cell) => cell == first && first != '')) {
          return first == 'X' ? GameState.winPlayer1 : GameState.winPlayer2;
        }
      }
    }
    if (board.every((row) => row.every((cell) => cell != ''))) {
      return GameState.draw;
    }

    return GameState.continueGame;
  }

  void insertMove(GameMove move) {
    lastMoves = move;
    if (board[move.row][move.col] == '') {
      board[move.row][move.col] = move.data!;
    }
  }

  Future<void> resetGame(BuildContext context) async {
    await context.resetGame(roomId);
    board = List.generate(boardSize, (_) => List.filled(boardSize, ''));
    lastMoves = null;
  }
}
