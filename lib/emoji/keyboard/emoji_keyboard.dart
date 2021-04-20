import 'package:emoji_keyboard/emoji/keyboard/bottom_bar.dart';
import 'package:emoji_keyboard/emoji/keyboard/category_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'emoji_page.dart';
import 'emoji_searching.dart';


class EmojiKeyboard extends StatefulWidget {

  final TextEditingController bromotionController;
  final double emojiKeyboardHeight;
  final bool showEmojiKeyboard;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
    this.emojiKeyboardHeight,
    this.showEmojiKeyboard
  }) : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {

  final GlobalKey<CategoryBarState> categoryBarStateKey = GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageStateKey = GlobalKey<EmojiPageState>();

  FocusNode focusSearchEmoji;
  final TextEditingController searchController = TextEditingController();
  List<String> searchedEmojis;

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
    BackButtonInterceptor.add(myInterceptor);

    super.initState();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (searchMode) {
      setState(() {
        searchMode = false;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    focusSearchEmoji.dispose();
    BackButtonInterceptor.remove(myInterceptor);
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
      List<SearchedEmoji> recommendedEmojis = [];
      if (value != null && value != []) {
        for (var val in value) {
          recommendedEmojis.add(SearchedEmoji(
              name: null,
              emoji: val.toString(),
              tier: 1));
          if (recommendedEmojis.length >= 10) {
            break;
          }
        }
        List<String> finalEmojis = [];
        recommendedEmojis.forEach((element) {
          finalEmojis.add(element.emoji.toString());
        });
        setState(() {
          searchedEmojis = finalEmojis;
        });
      }
    });
  }

  updateEmojiSearch(String text) {
    List finalEmojis = searchEmojis(text);
    if (finalEmojis != null && finalEmojis != []) {
      setState(() {
        searchedEmojis = finalEmojis.toList();
      });
    }
  }

  Future getRecentEmoji() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    return recent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: widget.showEmojiKeyboard && !searchMode ? emojiKeyboardHeight : 0,
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
            ),
            searchMode ? Container(
              color: Colors.yellow,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width / 6, // 6 items to fill screen
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Let the ListView know how many items it needs to build.
                      itemCount: searchedEmojis.length,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      itemBuilder: (context, index) {
                        return TextButton(
                            onPressed: () {
                              print("did a press thing ${searchedEmojis[index]}");
                            },
                            child: Text(
                                searchedEmojis[index],
                                style: TextStyle(
                                    fontSize: 40
                                )
                            )
                        );
                      },
                    ),
                  ),
                  TextFormField(
                    focusNode: focusSearchEmoji,
                    onChanged: (text) {
                      updateEmojiSearch(text);
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ],
              ),
            ) : Container(),
          ]
        )
    );
  }
}
