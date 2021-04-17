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
                bromotionController: bromotionController
              )
            )
          ]
      ),
    );
  }
}
