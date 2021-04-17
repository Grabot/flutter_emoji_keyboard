import 'package:emoji_keyboard/emoji/smileys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'emoji_page.dart';


class EmojiKeyboard extends StatefulWidget {

  final TextEditingController bromotionController;
  final double emojiKeyboardHeight;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
    this.emojiKeyboardHeight
  }) : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {

  double emojiKeyboardHeight;
  TextEditingController bromotionController;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;

    super.initState();
  }

  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: emojiKeyboardHeight,
      color: Colors.grey,
      child: Column(
          children: [
            SizedBox(
              height: emojiKeyboardHeight,
              child: EmojiPage(
                emojis: getEmojis(smileysList),
                bromotionController: bromotionController
              )
            )
          ]
      ),
    );
  }
}
