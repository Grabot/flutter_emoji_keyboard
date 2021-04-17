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

  final GlobalKey<CategoryBarState> categoryBarStateKey = GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageStateKey = GlobalKey<EmojiPageState>();

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
    emojiPageStateKey.currentState.navigateCategory(categoryNumber);
  }

  void emojiScrollShowBottomBar(bool emojiScrollShowBottomBar) {
    if (this.showBottomBar != emojiScrollShowBottomBar) {
      this.showBottomBar = emojiScrollShowBottomBar;
      bottomBarStateKey.currentState.emojiScrollShowBottomBar(this.showBottomBar);
    }
  }

  void switchedPage(int pageNumber) {
    categoryBarStateKey.currentState.updateCategoryBar(pageNumber);
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
            key: categoryBarStateKey,
            categoryHandler: categoryHandler
          ),
          Stack(
            children: [
              EmojiPage(
                key: emojiPageStateKey,
                bromotionController: bromotionController,
                emojiScrollShowBottomBar: emojiScrollShowBottomBar,
                switchedPage: switchedPage
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
