import 'package:tic_tac_toe_with_supabase/core/extensions/extensions.dart';

class BlockPicker extends StatefulWidget {
  final List<Color> availableColors;
  final void Function(Color) pickColor;
  const BlockPicker(
      {super.key, required this.availableColors, required this.pickColor});

  @override
  State<BlockPicker> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableColors
          .map(
            (color) => Material(
              elevation: 4,
              color: color,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  widget.pickColor(color);
                  context.pop();
                },
                child: const SizedBox(
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
