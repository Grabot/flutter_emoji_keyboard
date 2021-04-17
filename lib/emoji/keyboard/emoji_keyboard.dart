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

  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();

  double emojiKeyboardHeight;
  TextEditingController bromotionController;
  bool showBottomBar;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.showBottomBar = true;

    super.initState();
  }

  void categoryHandler(int categoryNumber) {
    print("pressed category $categoryNumber");
  }

  void emojiScrollShowBottomBar(bool emojiScrollShowBottomBar) {
    if (this.showBottomBar != emojiScrollShowBottomBar) {
      this.showBottomBar = emojiScrollShowBottomBar;
      bottomBarStateKey.currentState.emojiScrollShowBottomBar(this.showBottomBar);
    }
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
                bromotionController: bromotionController,
                emojiScrollShowBottomBar: emojiScrollShowBottomBar
              ),
              BottomBar(
                key: bottomBarStateKey,
              ),
            ]
          )
        ]
      ),
    );
  }
}
