import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'bottom_bar.dart';
import 'category_bar.dart';
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
  static const platform = const MethodChannel("nl.emojikeyboard.emoji/available");

  final GlobalKey<CategoryBarState> categoryBarStateKey = GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageStateKey = GlobalKey<EmojiPageState>();

  FocusNode focusSearchEmoji;
  final TextEditingController searchController = TextEditingController();
  List<String> searchedEmojis;
  TextSelection rememberPosition;

  double emojiKeyboardHeight;
  TextEditingController bromotionController;
  bool showBottomBar;
  bool searchMode;
  List<String> recent;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.showBottomBar = true;
    this.searchMode = false;
    this.searchedEmojis = [];

    this.recent = [];
    getRecentEmoji().then((value) {
      List<String> recentUsed = [];
      if (value != null && value != []) {
        for (var val in value) {
          recentUsed.add(val.toString());
        }
        setState(() {
          recent = recentUsed;
        });
        categoryHandler(0);
        switchedPage(0);
      }
    });

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        if (searchMode) {
          setState(() {
            searchMode = false;
          });
        }
      });

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
    rememberPosition = bromotionController.selection;
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
        isAvailable(finalEmojis);
        setState(() {
          searchedEmojis = finalEmojis;
        });
      }
    });
  }

  updateEmojiSearch(String text) {
    List<String> finalEmojis = searchEmojis(text);
    if (finalEmojis != null && finalEmojis != []) {
      isAvailable(finalEmojis.toList());
    }
  }

  Future getRecentEmoji() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    return recent;
  }

  void addRecentEmoji(String emoji) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    getRecentEmoji().then((value) {
      List<String> recentUsed = [];
      if (value != null) {
        for (var val in value) {
          recentUsed.add(val.toString());
        }
      }
      if (recentUsed == null || recentUsed == []) {
        recentUsed = [];
      } else {
        // If the emoji is already in the list, then remove it so it is added in the front.
        recentUsed.removeWhere((item) => item == emoji);
      }
      recentUsed.insert(0, emoji.toString());
      preferences.setStringList(recentEmojisKey, recent);
      setState(() {
        recent = recentUsed;
      });
    });
  }

  void insertTextSearch(String myText) {
    final text = bromotionController.text;
    final textSelection = rememberPosition;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
    setState(() {
      searchMode = false;
    });
  }

  isAvailable(recentEmojis) {
    if (Platform.isAndroid) {
      Future.wait([getAvailableEmojis(recentEmojis)])
          .then((var value) {
        setState(() {
        });
      });
    } else {
      setState(() {
        this.searchedEmojis = recentEmojis;
      });
    }
  }

  Future getAvailableEmojis(emojis) async {
    List availableResult = await platform.invokeMethod(
        "isAvailable", {"emojis": emojis});
    List<String> availables = [];
    for (var avail in availableResult) {
      availables.add(avail.toString());
    }
    this.searchedEmojis = availables;
  }

  void insertText(String myText) {
    addRecentEmoji(myText);
    emojiScrollShowBottomBar(true);
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
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
                        insertText: insertText,
                        recent: recent,
                        switchedPage: switchedPage
                      ),
                      BottomBar(
                        key: bottomBarStateKey,
                        bromotionController: bromotionController,
                        emojiSearch: emojiSearch,
                      ),
                    ]
                  )
                ]
              ),
            ),
            searchMode ? Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width / 8, // 8 items to fill screen
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      // Let the ListView know how many items it needs to build.
                      itemCount: searchedEmojis.length,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      itemBuilder: (context, index) {
                        return TextButton(
                            onPressed: () {
                              insertTextSearch(searchedEmojis[index]);
                            },
                            child: Text(
                                searchedEmojis[index],
                                style: TextStyle(
                                    fontSize: 25
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
