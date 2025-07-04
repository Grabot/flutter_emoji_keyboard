import 'package:flutter/material.dart';

/// This is the Bottom Bar of the Emoji Keyboard
class BottomBar extends StatefulWidget {
  final Function emojiSearch;
  final Function onActionSpaceBar;
  final Function onActionBackspace;
  final bool darkMode;

  const BottomBar(
      {required this.onActionSpaceBar, required this.onActionBackspace, required this.emojiSearch, required this.darkMode, Key? key})
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
  final double bottomBarHeight = 40;
  bool showBottomBar = true;

  @override
  void initState() {
    super.initState();
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
          height: showBottomBar ? (bottomBarHeight + MediaQuery.of(context).padding.bottom) : 0,
          width: MediaQuery.of(context).size.width,
          duration: const Duration(seconds: 1),
          child: Container(
            color: widget.darkMode ? const Color(0xff171717) : const Color(0xffdbdbdb),
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
                                child: const Icon(Icons.search))),
                        SizedBox(
                            width: (MediaQuery.of(context).size.width / 8) * 3,
                            height: MediaQuery.of(context).size.width / 8,
                            child: TextButton(
                                onPressed: () {
                                  widget.onActionSpaceBar();
                                },
                                child: const Icon(Icons.space_bar))),
                        SizedBox(
                            width: (MediaQuery.of(context).size.width / 8) * 2,
                            height: MediaQuery.of(context).size.width / 8,
                            child: TextButton(
                                onPressed: () {
                                  widget.onActionBackspace();
                                },
                                child: const Icon(Icons.backspace)))
                      ],
                    ),
                  )
                : Container(),
          ),
        ));
  }
}
