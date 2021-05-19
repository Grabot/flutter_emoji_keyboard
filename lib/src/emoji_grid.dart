import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class EmojiGridState extends State<EmojiGrid> {
  List? emojis;
  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    this.emojis = widget.emojis;

    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

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

  void pressedEmoji(String emoji) {
    widget.emojiScrollShowBottomBar(true);
    widget.insertText(emoji);
  }

  void forceUpdate(emojis) {
    setState(() {
      this.emojis = emojis;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
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
