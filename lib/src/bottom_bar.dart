import 'package:flutter/material.dart';

/// This is the Bottom Bar of the Emoji Keyboard
class BottomBar extends StatefulWidget {
  final TextEditingController emojiController;
  final Function emojiSearch;
  final bool darkMode;

  const BottomBar(
      {Key? key,
      required this.emojiController,
      required this.emojiSearch,
      required this.darkMode})
      : super(key: key);

  @override
  BottomBarState createState() => BottomBarState();
}

/// The bottom bar of the Emoji keyboard is visible when opening
/// the emoji keyboard. When the user scrolls down the bottom bar is hidden.
/// If the user then scrolls back up or presses an emoji the bottom bar
/// becomes visible and usable again.
/// The bottom bar has the "search" button with which the user can
/// search for a particular emoji using a regular keyboard.
class BottomBarState extends State<BottomBar> {
  TextEditingController? emojiController;
  final double bottomBarHeight = 40;
  bool showBottomBar = true;

  @override
  void initState() {
    emojiController = widget.emojiController;
    super.initState();
  }

  /// If the user presses the backspace located on the bottom bar it should
  /// remove the previous emoji (or character) based on where the cursor is
  /// at that moment.
  /// Using the skipLast(1) functionality we determine which that is and
  /// remove it.
  /// First we check if a selection is made, if that's the case we remove
  /// that selection
  /// if the user has the cursor in the beginning or nothing is in the
  /// Textfield nothing happens
  void onBackspace() {
    final text = emojiController!.text;
    final textSelection = emojiController!.selection;
    final selectionLength = textSelection.end - textSelection.start;
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      emojiController!.text = newText;
      emojiController!.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    if (textSelection.start == 0) {
      if (text.isEmpty) {
        return;
      } else {
        // Eagerly selects all but the last count characters
        String finalCharacter = text.characters.skipLast(1).string;
        // So if the result is empty there was only 1 character
        if (finalCharacter == "") {
          // If there was only 1 character we remove that one.
          emojiController!.text = "";
          emojiController!.selection = textSelection.copyWith(
            baseOffset: 0,
            extentOffset: 0,
          );
          return;
        }
      }
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
    emojiController!.text = newText;
    emojiController!.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  /// If the user presses the Spacebar it will simply add a space
  void onSpacebar() {
    final text = emojiController!.text;
    final textSelection = emojiController!.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      " ",
    );
    emojiController!.text = newText;
    emojiController!.selection = textSelection.copyWith(
      baseOffset: textSelection.start + 1,
      extentOffset: textSelection.start + 1,
    );
  }

  /// If the user scrolls down the bottom bar should be hidden.
  /// If the user scrolls up the bottom bar should be shown.
  /// If the user presses an emoji the bottom bar should also be shown
  /// A call is send to this function from the Emoji grid which handles the
  /// scrolling and it will set the visible boolean here to hide or show it
  void emojiScrollShowBottomBar(bool show) {
    if (show != showBottomBar) {
      setState(() {
        showBottomBar = show;
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
          height: showBottomBar
              ? (bottomBarHeight + MediaQuery.of(context).padding.bottom)
              : 0,
          width: MediaQuery.of(context).size.width,
          duration: Duration(seconds: 1),
          child: Container(
            color: widget.darkMode ? Color(0xff171717) : Color(0xffdbdbdb),
            alignment: Alignment.topCenter,
            child: showBottomBar
                ? SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: (MediaQuery.of(context).size.width / 8) * 2,
                            height: MediaQuery.of(context).size.width / 8,
                            child: TextButton(
                                onPressed: () {
                                  widget.emojiSearch();
                                },
                                child: Icon(Icons.search))),
                        SizedBox(
                            width: (MediaQuery.of(context).size.width / 8) * 3,
                            height: MediaQuery.of(context).size.width / 8,
                            child: TextButton(
                                onPressed: () {
                                  onSpacebar();
                                },
                                child: Icon(Icons.space_bar))),
                        SizedBox(
                            width: (MediaQuery.of(context).size.width / 8) * 2,
                            height: MediaQuery.of(context).size.width / 8,
                            child: TextButton(
                                onPressed: () {
                                  onBackspace();
                                },
                                child: Icon(Icons.backspace)))
                      ],
                    ),
                  )
                : Container(),
          ),
        ));
  }
}
