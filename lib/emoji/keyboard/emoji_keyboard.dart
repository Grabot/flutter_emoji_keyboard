import 'package:emoji_keyboard/emoji/keyboard/bottom_bar.dart';
import 'package:emoji_keyboard/emoji/keyboard/category_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  FocusNode focusSearchEmoji;
  final TextEditingController searchController = TextEditingController();
  List searchedEmojis;

  double emojiKeyboardHeight;
  TextEditingController bromotionController;
  bool showBottomBar;
  bool searchMode;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.showBottomBar = true;
    this.searchMode = false;
    this.searchedEmojis = [];

    this.focusSearchEmoji = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    focusSearchEmoji.dispose();
    super.dispose();
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

  static String recentEmojisKey = "recentEmojis";
  void emojiSearch() {
    setInitialSearchEmojis();
    setState(() {
      this.searchMode = true;
    });
    focusSearchEmoji.requestFocus();
  }

  setInitialSearchEmojis() {
    getRecentEmoji().then((value) {
      List<String> recentUsed = [];
      if (value != null && value != []) {
        for (var val in value) {
          recentUsed.add(val.toString());
          if (recentUsed.length >= 10) {
            break;
          }
        }
        setState(() {
          searchedEmojis = recentUsed;
        });
      }
    });
  }

  Future getRecentEmoji() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    return recent;
  }

  @override
  Widget build(BuildContext context) {
    return searchMode ? Container(
      height: 160.0,
      alignment: Alignment.bottomCenter,
      child: Column(
        children:
        [
          Container(
            height: 160.0,
            child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: searchedEmojis.length,
            itemBuilder: (BuildContext ctx, index) {
              return TextButton(
                  onPressed: () {
                    print(searchedEmojis[index]);
                  },
                  child: Text(
                      searchedEmojis[index],
                      style: TextStyle(
                          fontSize: 25
                      )
                  )
              );
            }
           ),
          ),
          TextFormField(
            focusNode: focusSearchEmoji,
            controller: searchController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ]
      )
    ) : Container(
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
                emojiKeyboardHeight: emojiKeyboardHeight,
                bromotionController: bromotionController,
                emojiScrollShowBottomBar: emojiScrollShowBottomBar,
                switchedPage: switchedPage
              ),
              BottomBar(
                key: bottomBarStateKey,
                bromotionController: bromotionController,
                emojiSearch: emojiSearch
              ),
            ]
          )
        ]
      ),
    );
  }
}
