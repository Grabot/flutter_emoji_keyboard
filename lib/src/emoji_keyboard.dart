import 'dart:io';
import 'package:emoji_keyboard_flutter/src/util/emoji.dart';
import 'package:emoji_keyboard_flutter/src/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'bottom_bar.dart';
import 'category_bar.dart';
import 'emoji_page.dart';
import 'emoji_searching.dart';

/// The emoji keyboard. This holds all the components of the keyboard.
/// This will include the:
///   - category bar
///     This holds the categories
///   - bottom bar
///     This holds the backspace, search and normal space functionality
///   - emoji pages
///     These hold all the emojis in 9 separate listviews.
class EmojiKeyboard extends StatefulWidget {
  final TextEditingController emotionController;
  final double emojiKeyboardHeight;
  final bool showEmojiKeyboard;
  final bool darkMode;

  EmojiKeyboard(
      {Key? key,
      required this.emotionController,
      this.emojiKeyboardHeight = 350,
      this.showEmojiKeyboard = true,
      this.darkMode = false})
      : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

/// The emojiboard has a configurable textfield which is will control
/// It has a configurable height and it can be made visible or invisible
/// using the showKeyboard boolean
/// It also has a darkmode for the users with a good taste in styling.
class EmojiBoard extends State<EmojiKeyboard> {
  /// The name of the channel that Android will call when adding an emoji.
  /// This function will see if it can be shown in the Android version
  /// that the user is currently using.
  /// (See MainActivity in the android project for the implementation)
  static const platform = const MethodChannel("nl.brocast.emoji/available");

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
  List<Emoji> recent = [];
  List<String> recentEmojis = [];

  Storage storage = Storage();

  @override
  void initState() {
    this.bromotionController = widget.emotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.darkMode = widget.darkMode;

    storage.fetchAllEmojis().then((emojis) {
      if (emojis.isNotEmpty) {
        recent = emojis;
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        recentEmojis = recent.map((emote) => emote.emoji).toList();

        if (mounted) {
          setState(() {});
        }
      }

      if (recent.isEmpty) {
        categoryHandler(1);
        switchedPage(1);
      } else {
        categoryHandler(0);
        switchedPage(0);
      }
    });

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        if (searchMode) {
          searchMode = false;
          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {});
          });
        }
      }
    });

    BackButtonInterceptor.add(myInterceptor);

    super.initState();
  }

  /// We intercept any back button trigger. If the user has the emoji keyboard
  /// open it will first override the back functionality by just hiding the
  /// emoji keyboard first. If the back button is called again the normal
  /// back functionality will apply.
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (searchMode) {
      searchMode = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
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

  /// This function handles any changes to the category from the
  /// category bar and passes it to the emoji page widget.
  void categoryHandler(int categoryNumber) {
    if (emojiPageStateKey.currentState != null) {
      emojiPageStateKey.currentState!.navigateCategory(categoryNumber);
    }
  }

  /// This function handles any triggers to hide or show the bottom bar if the
  /// user scrolls up or down on the emoji page. It sends this trigger to the
  /// bottom bar
  void emojiScrollShowBottomBar(bool emojiScrollShowBottomBar) {
    if (this.showBottomBar != emojiScrollShowBottomBar) {
      this.showBottomBar = emojiScrollShowBottomBar;
      if (bottomBarStateKey.currentState != null) {
        bottomBarStateKey.currentState!
            .emojiScrollShowBottomBar(this.showBottomBar);
      }
    }
  }

  /// This function handles changes in the Emoji page if the user swipes
  /// left or right.
  /// It sends a trigger to the category bar to update the category
  void switchedPage(int pageNumber) {
    if (categoryBarStateKey.currentState != null) {
      categoryBarStateKey.currentState!.updateCategoryBar(pageNumber);
    }
  }

  /// If the user presses the "search" button this function is called.
  /// It sets the initial emojis, which is the recent page.
  /// It remembers the position that the cursor was at and it will shift focus
  /// to the new keyboard which will be called up.
  void emojiSearch() {
    setInitialSearchEmojis();
    setState(() {
      this.searchMode = true;
    });
    rememberPosition = bromotionController!.selection;
    focusSearchEmoji.requestFocus();
  }

  /// The function which will set the initial search emojis when the "search"
  /// button is pressed. It takes the recent emojis and fills it in.
  /// It stops after 10 because more is not needed.
  setInitialSearchEmojis() {
    List<SearchedEmoji> recommendedEmojis = [];
    if (recentEmojis != []) {
      for (var recentEmoji in recentEmojis) {
        recommendedEmojis
            .add(SearchedEmoji(emoji: recentEmoji.toString(), tier: 1));
        if (recommendedEmojis.length >= 20) {
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
  }

  /// Every letter that the user inputs in the search mode will trigger this
  /// function.
  /// It will take the text entered so far and find all emojis which are
  /// related to that text search in any way. It puts these emojis in the list
  /// and shows it.
  updateEmojiSearch(String text) {
    List<String> finalEmojis = searchEmojis(text);
    if (finalEmojis != []) {
      isAvailable(finalEmojis.toList());
    }
  }

  /// If the user presses an emoji it is added to it's "recent" list.
  /// This is a list of emojis in a local db
  /// It looks to see if it is present in the 'recent emoji' list.
  /// If that is true than it should be in the database and we update it.
  /// If that is not true, we add a new entry for the database.
  /// When it adds a new entry it will look in the emoji list for the category
  /// that the emoji is in to be able to store a new entry in the local db
  void addRecentEmoji(String emoji, int category) async {
    List<String> recentEmojiList = recent.map((emote) => emote.emoji).toList();
    if (recentEmojiList.contains(emoji)) {
      // The emoji is already in the list so we want to update it.
      Emoji currentEmoji = recent.firstWhere((emote) => emote.emoji == emoji);
      currentEmoji.increase();
      storage.updateEmoji(currentEmoji).then((value) {
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    } else {
      Emoji newEmoji = Emoji(emoji, 1);
      storage.addEmoji(newEmoji).then((emotion) {
        recent.add(newEmoji);
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    }
  }

  /// The add recent emoji search does the same as the `addRecentEmoji` function
  /// But here we don't have access to the category, so we will loop through
  /// all the categories to find the emoji we want to add
  addRecentEmojiSearch(String emoji) async {
    List<String> recentEmojiList = recent.map((emote) => emote.emoji).toList();
    if (recentEmojiList.contains(emoji)) {
      // The emoji is already in the list so we want to update it.
      Emoji currentEmoji = recent.firstWhere((emote) => emote.emoji == emoji);
      currentEmoji.increase();
      storage.updateEmoji(currentEmoji).then((value) {
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    } else {
      Emoji newEmoji = Emoji(emoji, 1);
      storage.addEmoji(newEmoji).then((emotion) {
        recent.add(newEmoji);
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    }
  }

  /// If the user has searched for an emoji using the search functionality
  /// it can select any emoji and it will insert this emoji in the Textfield.
  /// It will then go out of search mode and back to the emoji keyboard.
  /// The emoji is added where the cursor was when the user pressed search.
  void insertTextSearch(String myText) {
    addRecentEmojiSearch(myText);
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
    rememberPosition = bromotionController!.selection;
  }

  /// This function is called when we want to see if any of the recent emojis
  /// that the user used can be shown in this Android version.
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

  /// If the emoji cannot be shown in this Android version it is removed from
  /// the list.
  Future getAvailableEmojis(emojis) async {
    List availableResult =
        await (platform.invokeMethod("isAvailable", {"emojis": emojis}));
    List<String> availables = [];
    for (var avail in availableResult) {
      availables.add(avail.toString());
    }
    this.searchedEmojis = availables;
  }

  /// If the user selects an emoji from the grid a trigger is send to this
  /// function with the corresponding emoji that the user pressed.
  /// The emoji is added to the Textfield at the location of the cursor
  /// or as a replacement of the selection of the user.
  void insertText(String myText, int category) {
    addRecentEmoji(myText, category);
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

  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  pressedBackSearch() {
    if (searchMode) {
      // Hide the keyboard
      FocusManager.instance.primaryFocus?.unfocus();
      searchMode = false;
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: widget.showEmojiKeyboard && !searchMode
              ? isPortrait()
                  ? emojiKeyboardHeight
                  : 150
              : 0,
          color: this.darkMode ? Color(0xff373737) : Color(0xffc5c5c5),
          child: Column(children: [
            CategoryBar(
                key: categoryBarStateKey,
                categoryHandler: categoryHandler,
                darkMode: darkMode),
            Stack(children: [
              EmojiPage(
                  key: emojiPageStateKey,
                  emojiKeyboardHeight: isPortrait() ? emojiKeyboardHeight : 150,
                  bromotionController: bromotionController!,
                  emojiScrollShowBottomBar: emojiScrollShowBottomBar,
                  insertText: insertText,
                  recent: recentEmojis,
                  switchedPage: switchedPage),
              BottomBar(
                  key: bottomBarStateKey,
                  bromotionController: bromotionController!,
                  emojiSearch: emojiSearch,
                  darkMode: darkMode),
            ])
          ]),
        ),
        widget.showEmojiKeyboard && searchMode
            ? Container(
                color: this.darkMode ? Color(0xff373737) : Color(0xffc5c5c5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: isPortrait()
                          ? MediaQuery.of(context).size.width / 8
                          : 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: searchedEmojis.length,
                        itemBuilder: (context, index) {
                          return TextButton(
                              onPressed: () {
                                insertTextSearch(searchedEmojis[index]);
                              },
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(searchedEmojis[index],
                                    style: TextStyle(fontSize: 50)),
                              ));
                        },
                      ),
                    ),
                    Row(children: [
                      Container(
                          child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.grey.shade600,
                        onPressed: () {
                          pressedBackSearch();
                        },
                      )),
                      Expanded(
                        child: TextFormField(
                            focusNode: focusSearchEmoji,
                            onChanged: (text) {
                              updateEmojiSearch(text);
                            },
                            style: TextStyle(
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none)),
                      ),
                    ]),
                  ],
                ),
              )
            : Container(),
      ])),
    );
  }
}
