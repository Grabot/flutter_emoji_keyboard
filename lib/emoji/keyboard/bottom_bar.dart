
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {

  final TextEditingController bromotionController;

  BottomBar({
    Key key,
    this.bromotionController,
  }):super(key:key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {

  TextEditingController bromotionController;
  final double bottomBarHeight = 50;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    super.initState();
  }

  void onBackspace() {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final selectionLength = textSelection.end - textSelection.start;
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      bromotionController.text = newText;
      bromotionController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    if (textSelection.start == 0) {
      return;
    }

    String firstSection = text.substring(0, textSelection.start);
    String newFirstSection = firstSection.characters.skipLast(1).string;
    final offset = firstSection.length - newFirstSection.length;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void onSpacebar() {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      " ",
    );
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + 1,
      extentOffset: textSelection.start + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      alignment: Alignment.bottomCenter,
      child:SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 8,
                child: TextButton(
                    onPressed: () {
                      print("pressed search");
                    },
                    child: Icon(Icons.search)
                )
            ),
            SizedBox(
                width: (MediaQuery.of(context).size.width / 8)*3,
                height: MediaQuery.of(context).size.width / 8,
                child: TextButton(
                    onPressed: () {
                      onSpacebar();
                    },
                    child: Icon(Icons.space_bar)
                )
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
                height: MediaQuery.of(context).size.width / 8, // make it square
                child: TextButton(
                    onPressed: () {
                      onBackspace();
                    },
                    child: Icon(Icons.backspace)
                )
            )
          ],
        ),
      ),
    );
  }
}
