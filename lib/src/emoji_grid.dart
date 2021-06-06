import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This is the Grid which will hold all the emojis
class EmojiGrid extends StatefulWidget {
  final List emojis;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String) insertText;

  EmojiGrid({
    Key? key,
    required this.emojis,
    required this.emojiScrollShowBottomBar,
    required this.insertText,
  }) : super(key: key);

  @override
  EmojiGridState createState() => EmojiGridState();
}

/// The grid will consist of a listview.
/// There are 9 separate listviews, each corresponding to a category.
/// For each category all the emojis are shown in this listview
/// A gridview.builder is used for performance. So not all the emojis have
/// to be loaded immediately but are loaded if the user scrolls.
class EmojiGridState extends State<EmojiGrid> {
  List? emojis;
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    this.emojis = widget.emojis;

    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  /// If the user scroll in the emoji we keep track of when the direction
  /// changes.
  /// If the user scrolls down a trigger is send to the bottom bar
  /// to hide the bottom bar if it was visible.
  /// If the user scrolls back up a trigger is send again to show the
  /// bottom bar if it was hidden
  keyboardScrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.emojiScrollShowBottomBar(false);
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.emojiScrollShowBottomBar(true);
      }
    }
  }

  /// If an emoji is pressed in the grid this function is called with the
  /// unicode of the emoji that is pressed.
  /// Here it sends a trigger to the "insertText" function in the EmojiKeyboard
  /// to insert the text in the Textfield.
  void pressedEmoji(String emoji) {
    widget.emojiScrollShowBottomBar(true);
    widget.insertText(emoji);
  }

  /// If the emojis are loaded the grid is already visible.
  /// We pass the emojis to the grid and we set the state to redraw the keyboard
  /// This will show the emojis correctly
  void forceUpdate(emojis) {
    setState(() {
      this.emojis = emojis;
    });
  }

  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPortrait() ? 8 : 16,
        ),
        itemCount: emojis!.length,
        itemBuilder: (BuildContext ctx, index) {
          return TextButton(
              onPressed: () {
                pressedEmoji(emojis![index]);
              },
              child: Text(emojis![index], style: TextStyle(fontSize: 25)));
        });
  }
}
