import 'package:tic_tac_toe_with_supabase/core/enum/enum.dart';
import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';
import 'package:tic_tac_toe_with_supabase/infrastructure/models/game_room.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class GameCreate extends StatefulWidget {
  const GameCreate({super.key});

  @override
  State<GameCreate> createState() => _GameCreateState();
}

class _GameCreateState extends State<GameCreate> {
  final TextEditingController _roomNameController = TextEditingController();
  BoardType _boardType = BoardType.board3x3;
  Color boardColor = Colors.white;
  int winCondition = 3;
  GameRoom? gameRoom;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Game'),
          actions: [
            Text(
              'Board Color: ',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Material(
              elevation: 4,
              color: boardColor,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: pickColor,
                child: SizedBox(
                  width: 40,
                  height: 36,
                  child: Icon(Icons.edit, color: boardColor.getTextColor()),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  labelText: "Room Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Board Type',
                textAlign: TextAlign.start,
                style: context.textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: BoardType.values
                    .map(
                      (e) => Row(
                        children: [
                          Radio(
                            value: e,
                            groupValue: _boardType,
                            onChanged: _changeBoardType,
                          ),
                          Text(e.name),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Win Condition',
                textAlign: TextAlign.start,
                style: context.textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 3,
                        groupValue: winCondition,
                        onChanged: changeWinCondition,
                      ),
                      const Text('3'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 4,
                        groupValue: winCondition,
                        onChanged: _boardType != BoardType.board3x3
                            ? changeWinCondition
                            : null,
                      ),
                      const Text('4'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 5,
                        groupValue: winCondition,
                        onChanged: _boardType == BoardType.board5x5
                            ? changeWinCondition
                            : null,
                      ),
                      const Text('5'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final roomName = _roomNameController.text;
                      if (roomName.isEmpty) {
                        context.showErrorSnackBar('Please enter room name');
                        return;
                      }

                      final gameRoom = GameRoom(
                        roomName: roomName,
                        boardColor: boardColor.toHex(),
                        boardType: _boardType.name,
                        winCondition: winCondition,
                        createdBy: context.userId!,
                        status: true,
                      );
                      setState(() => isLoading = true);
                      try {
                        final returnRomm = (await context.games
                                .insert(gameRoom.toJson(), defaultToNull: false)
                                .select())
                            .first;
                        if (context.mounted) {
                          setState(() => isLoading = false);
                          final room = GameRoom.fromJson(returnRomm);
                          context.push(Paths.game, query: '/${room.roomId}');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showErrorSnackBar('Error creating game');
                        }
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Game'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeWinCondition(value) {
    setState(() {
      winCondition = value as int;
    });
  }

  void _changeBoardType(value) {
    setState(() {
      _boardType = value as BoardType;
    });
  }

  void changeColor(Color color) => setState(() => boardColor = color);

  void pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: Colors.white,
              onColorChanged: changeColor,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
