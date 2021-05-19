import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
  final bool darkMode;

  EmojiKeyboard(
      {
        Key? key,
        required this.bromotionController,
        this.emojiKeyboardHeight = 350,
        this.showEmojiKeyboard = true,
        this.darkMode = false
      })
      : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {
  static const platform =
      const MethodChannel("nl.emojikeyboard.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  final GlobalKey<CategoryBarState> categoryBarStateKey =
      GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarStateKey =
      GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageStateKey =
      GlobalKey<EmojiPageState>();

  FocusNode focusSearchEmoji = FocusNode();

  final TextEditingController searchController = TextEditingController();
  List<String> searchedEmojis = [];

  late TextSelection rememberPosition;

  double emojiKeyboardHeight = 350;

  TextEditingController? bromotionController;

  bool showBottomBar = true;
  bool searchMode = false;
  bool darkMode = false;
  List<String> recent = [];

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.darkMode = widget.darkMode;

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

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        if (searchMode) {
          setState(() {
            searchMode = false;
          });
        }
      }
    });

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
    emojiPageStateKey.currentState!.navigateCategory(categoryNumber);
  }

  void emojiScrollShowBottomBar(bool emojiScrollShowBottomBar) {
    if (this.showBottomBar != emojiScrollShowBottomBar) {
      this.showBottomBar = emojiScrollShowBottomBar;
      bottomBarStateKey.currentState!
          .emojiScrollShowBottomBar(this.showBottomBar);
    }
  }

  void switchedPage(int pageNumber) {
    categoryBarStateKey.currentState!.updateCategoryBar(pageNumber);
  }

  void emojiSearch() {
    setInitialSearchEmojis();
    setState(() {
      this.searchMode = true;
    });
    rememberPosition = bromotionController!.selection;
    focusSearchEmoji.requestFocus();
  }

  setInitialSearchEmojis() {
    getRecentEmoji().then((value) {
      List<SearchedEmoji> recommendedEmojis = [];
      if (value != null && value != []) {
        for (var val in value) {
          recommendedEmojis
              .add(SearchedEmoji(name: "", emoji: val.toString(), tier: 1));
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
    List<String>? recent = preferences.getStringList(recentEmojisKey);
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
    final text = bromotionController!.text;
    final textSelection = rememberPosition;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController!.text = newText;
    bromotionController!.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
    setState(() {
      searchMode = false;
    });
  }

  isAvailable(recentEmojis) {
    if (Platform.isAndroid) {
      Future.wait([getAvailableEmojis(recentEmojis)]).then((var value) {
        setState(() {});
      });
    } else {
      setState(() {
        this.searchedEmojis = recentEmojis;
      });
    }
  }

  Future getAvailableEmojis(emojis) async {
    List availableResult =
        await (platform.invokeMethod("isAvailable", {"emojis": emojis}));
    List<String> availables = [];
    for (var avail in availableResult) {
      availables.add(avail.toString());
    }
    this.searchedEmojis = availables;
  }

  void insertText(String myText) {
    addRecentEmoji(myText);
    emojiScrollShowBottomBar(true);
    final text = bromotionController!.text;
    final textSelection = bromotionController!.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController!.text = newText;
    bromotionController!.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        height:
            widget.showEmojiKeyboard && !searchMode ? emojiKeyboardHeight : 0,
        color: this.darkMode ? Color(0xff262626) : Color(0xffe7e7e7),
        child: Column(children: [
          CategoryBar(
              key: categoryBarStateKey,
              categoryHandler: categoryHandler,
              darkMode: darkMode),
          Stack(children: [
            EmojiPage(
                key: emojiPageStateKey,
                emojiKeyboardHeight: emojiKeyboardHeight,
                bromotionController: bromotionController!,
                emojiScrollShowBottomBar: emojiScrollShowBottomBar,
                insertText: insertText,
                recent: recent,
                switchedPage: switchedPage),
            BottomBar(
                key: bottomBarStateKey,
                bromotionController: bromotionController!,
                emojiSearch: emojiSearch,
                darkMode: darkMode
            ),
          ])
        ]),
      ),
      searchMode
          ? Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width /
                        8,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: searchedEmojis.length,
                      itemBuilder: (context, index) {
                        return TextButton(
                            onPressed: () {
                              insertTextSearch(searchedEmojis[index]);
                            },
                            child: Text(searchedEmojis[index],
                                style: TextStyle(fontSize: 25)));
                      },
                    ),
                  ),
                  TextFormField(
                    focusNode: focusSearchEmoji,
                    onChanged: (text) {
                      updateEmojiSearch(text);
                    },
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ],
              ),
            )
          : Container(),
    ]));
  }
}
