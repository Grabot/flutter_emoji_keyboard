
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {

  final TextEditingController bromotionController;
  final Function emojiSearch;

  BottomBar({
    Key key,
    this.bromotionController,
    this.emojiSearch,
  }):super(key:key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {

  TextEditingController bromotionController;
  final double bottomBarHeight = 50;
  bool showBottomBar;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.showBottomBar = true;
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

  void emojiScrollShowBottomBar(bool show) {
    if (show != showBottomBar) {
      setState(() {
        this.showBottomBar = show;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0.0,
        right: 0.0,
        left: 0.0,
        child: AnimatedContainer(
          curve: Curves.fastOutSlowIn,
          height: showBottomBar ? 40 : 0,
          width: MediaQuery.of(context).size.width,
            duration: new Duration(seconds: 1),
            child: Container(
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
                              widget.emojiSearch();
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
            ),
        )
    );
  }
}
