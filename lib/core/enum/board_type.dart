enum BoardType {
  board3x3,
  board4x4,
  board5x5;

  String get name {
    switch (this) {
      case BoardType.board3x3:
        return '3x3';
      case BoardType.board4x4:
        return '4x4';
      case BoardType.board5x5:
        return '5x5';
    }
  }

  int get size {
    switch (this) {
      case BoardType.board3x3:
        return 3;
      case BoardType.board4x4:
        return 4;
      case BoardType.board5x5:
        return 5;
    }
  }

  @override
  String toString() {
    return name;
  }
}
