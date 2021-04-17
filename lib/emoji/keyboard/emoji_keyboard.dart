import 'package:emoji_keyboard/emoji/keyboard/bottom_bar.dart';
import 'package:emoji_keyboard/emoji/keyboard/category_bar.dart';
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

  void categoryHandler(int categoryNumber) {
    print("pressed category $categoryNumber");
  }

  // TODO: @Skools pass height through widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      height: emojiKeyboardHeight,
      color: Colors.grey,
      child: Column(
          children: [
          CategoryBar(
            categoryHandler: categoryHandler
          ),
          Stack(
            children: [
              EmojiPage(
                bromotionController: bromotionController
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                left: 0.0,
                child: AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  duration: new Duration(seconds: 1),
                  child: BottomBar(

                  ),
                )
              ),
            ]
          )
        ]
      ),
    );
  }
}
