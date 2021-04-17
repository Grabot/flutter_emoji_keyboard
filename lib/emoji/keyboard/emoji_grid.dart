import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmojiGrid extends StatefulWidget {

  final List emojis;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String) insertText;

  EmojiGrid({
    Key key,
    this.emojis,
    this.emojiScrollShowBottomBar,
    this.insertText,
  }) : super(key: key);

  @override
  _EmojiGridState createState() => _EmojiGridState();
}

class _EmojiGridState extends State<EmojiGrid> {

  List emojis;
  ScrollController scrollController;

  @override
  void initState() {
    this.emojis = widget.emojis;

    scrollController = new ScrollController();
    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  keyboardScrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        print("reached the bottom of the scrollview");
      }
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
  void pressedEmoji(String emoji) {
    widget.emojiScrollShowBottomBar(true);
    widget.insertText(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: emojis.length,
        itemBuilder: (BuildContext ctx, index) {
          return TextButton(
              onPressed: () {
                pressedEmoji(emojis[index]);
              },
              child: Text(
                  emojis[index],
                  style: TextStyle(
                      fontSize: 25
                  )
              )
          );
        }
    );
  }
}
