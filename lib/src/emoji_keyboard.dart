import 'dart:async';
import 'dart:io';

import 'package:emoji_keyboard_flutter/src/bottom_bar.dart';
import 'package:emoji_keyboard_flutter/src/category_bar.dart';
import 'package:emoji_keyboard_flutter/src/emoji_page.dart';
import 'package:emoji_keyboard_flutter/src/emoji_searching.dart';
import 'package:emoji_keyboard_flutter/src/util/emoji.dart';
import 'package:emoji_keyboard_flutter/src/util/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

/// The emoji keyboard. This holds all the components of the keyboard.
/// This will include the:
///   - category bar
///     This holds the categories
///   - bottom bar
///     This holds the backspace, search and normal space functionality
///   - emoji pages
///     These hold all the emojis in 9 separate listviews.
class EmojiKeyboard extends StatefulWidget {
  final TextEditingController? emojiController;
  final void Function(String)? onEmojiChanged;
  final double emojiKeyboardHeight;
  final bool showEmojiKeyboard;
  final bool darkMode;
  final Duration? emojiKeyboardAnimationDuration;

  const EmojiKeyboard(
      {Key? key,
      this.emojiController,
      this.onEmojiChanged,
      this.emojiKeyboardHeight = 350,
      this.showEmojiKeyboard = true,
      this.darkMode = false,
      this.emojiKeyboardAnimationDuration})
      : assert(emojiController != null || onEmojiChanged != null,
            'Either emojiController or onEmojiChanged must be provided'),
        super(key: key);

  @override
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
  static const platform = MethodChannel('nl.emojikeyboard.emoji/available');

  final GlobalKey<CategoryBarState> categoryBarStateKey =
      GlobalKey<CategoryBarState>();
  final GlobalKey<BottomBarState> bottomBarStateKey =
      GlobalKey<BottomBarState>();
  final GlobalKey<EmojiPageState> emojiPageStateKey =
      GlobalKey<EmojiPageState>();

  FocusNode focusSearchEmoji = FocusNode();

  List<String> searchedEmojis = [];

  late TextSelection rememberPosition;

  double emojiKeyboardHeight = 350;

  bool showBottomBar = true;
  bool searchMode = false;
  bool darkMode = false;
  List<Emoji> recent = [];
  List<String> recentEmojis = [];

  Storage storage = Storage();

  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    emojiKeyboardHeight = widget.emojiKeyboardHeight;
    darkMode = widget.darkMode;

    storage.fetchAllEmojis().then((emojis) {
      if (emojis.isNotEmpty) {
        recent = emojis;
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        recentEmojis = recent.map((emote) => emote.emoji).toList();
        setState(() {});
      }

      if (recentEmojis.isEmpty) {
        categoryHandler(1);
        switchedPage(1);
      } else {
        categoryHandler(0);
        switchedPage(0);
      }
    });

    final KeyboardVisibilityController keyboardVisibilityController =
        KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      // If the keyboard was visible the user must have been in search mode.
      // If the keyboard is no longer visible the user must have pressed the back button
      // To handle this situation correctly we then set search mode to false and rebuild the widget.
      if (!visible && widget.showEmojiKeyboard) {
        searchMode = false;
        if (widget.emojiKeyboardAnimationDuration != null) {
          Future.delayed(widget.emojiKeyboardAnimationDuration!, () {
            setState(() {});
          });
        } else {
          setState(() {});
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    focusSearchEmoji.dispose();
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
  void emojiScrollShowBottomBar({required bool emojiScrollShowBottomBar}) {
    if (showBottomBar != emojiScrollShowBottomBar) {
      showBottomBar = emojiScrollShowBottomBar;
      if (bottomBarStateKey.currentState != null) {
        bottomBarStateKey.currentState!
            .emojiScrollShowBottomBar(show: showBottomBar);
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
    searchMode = true;
    if (widget.emojiController != null) {
      rememberPosition = widget.emojiController!.selection;
    }
    if (widget.emojiKeyboardAnimationDuration != null) {
      Future.delayed(widget.emojiKeyboardAnimationDuration!, () {
        focusSearchEmoji.requestFocus();
        setState(() {});
      });
    } else {
      focusSearchEmoji.requestFocus();
      setState(() {});
    }
  }

  /// The function which will set the initial search emojis when the "search"
  /// button is pressed. It takes the recent emojis and fills it in.
  /// It stops after 10 because more is not needed.
  void setInitialSearchEmojis() {
    final List<SearchedEmoji> recommendedEmojis = [];
    if (recentEmojis != <String>[]) {
      for (final String recentEmoji in recentEmojis) {
        recommendedEmojis.add(SearchedEmoji(emoji: recentEmoji, tier: 1));
        if (recommendedEmojis.length >= 20) {
          break;
        }
      }
      final List<String> finalEmojis = [];
      for (final SearchedEmoji element in recommendedEmojis) {
        finalEmojis.add(element.emoji);
      }
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
  void updateEmojiSearch(String text) {
    final List<String> finalEmojis = searchEmojis(text);
    if (finalEmojis != <String>[]) {
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
  Future<void> addRecentEmoji(String emoji, int category) async {
    final List<String> recentEmojiList =
        recent.map((emote) => emote.emoji).toList();
    if (recentEmojiList.contains(emoji)) {
      // The emoji is already in the list so we want to update it.
      final Emoji currentEmoji =
          recent.firstWhere((emote) => emote.emoji == emoji);
      currentEmoji.increase();
      storage.updateEmoji(currentEmoji).then((value) {
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    } else {
      final Emoji newEmoji = Emoji(emoji, 1);
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
  Future<void> addRecentEmojiSearch(String emoji) async {
    final List<String> recentEmojiList =
        recent.map((emote) => emote.emoji).toList();
    if (recentEmojiList.contains(emoji)) {
      // The emoji is already in the list so we want to update it.
      final Emoji currentEmoji =
          recent.firstWhere((emote) => emote.emoji == emoji);
      currentEmoji.increase();
      storage.updateEmoji(currentEmoji).then((value) {
        recent.sort((a, b) => b.amount.compareTo(a.amount));
        setState(() {
          recentEmojis = recent.map((emote) => emote.emoji).toList();
        });
      });
    } else {
      final Emoji newEmoji = Emoji(emoji, 1);
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
    if (widget.emojiController != null) {
      final text = widget.emojiController!.text;
      final textSelection = rememberPosition;
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        myText,
      );
      final myTextLength = myText.length;
      widget.emojiController!.text = newText;
      widget.emojiController!.selection = textSelection.copyWith(
        baseOffset: textSelection.start + myTextLength,
        extentOffset: textSelection.start + myTextLength,
      );
      rememberPosition = widget.emojiController!.selection;
    }
    widget.onEmojiChanged?.call(myText);
  }

  /// This function is called when we want to see if any of the recent emojis
  /// that the user used can be shown in this Android version.
  void isAvailable(List<String> recentEmojis) {
    if (Platform.isAndroid) {
      Future.wait([getAvailableEmojis(recentEmojis)]).then((var value) {
        setState(() {});
      });
    } else {
      setState(() {
        searchedEmojis = recentEmojis;
      });
    }
  }

  /// If the emoji cannot be shown in this Android version it is removed from
  /// the list.
  Future<void> getAvailableEmojis(List<String> emojis) async {
    final List<dynamic>? availableResult =
        await platform.invokeMethod('isAvailable', {'emojis': emojis});
    final List<String> available = [];
    if (availableResult != null) {
      for (final avail in availableResult) {
        available.add(avail.toString());
      }
    }
    searchedEmojis = available;
  }

  /// If the user selects an emoji from the grid a trigger is send to this
  /// function with the corresponding emoji that the user pressed.
  /// The emoji is added to the Textfield at the location of the cursor
  /// or as a replacement of the selection of the user.
  void insertText(String myText, int category) {
    addRecentEmoji(myText, category);
    emojiScrollShowBottomBar(emojiScrollShowBottomBar: true);
    if (widget.emojiController != null) {
      final text = widget.emojiController!.text;
      final textSelection = widget.emojiController!.selection;
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        myText,
      );
      final myTextLength = myText.length;
      widget.emojiController!.text = newText;
      widget.emojiController!.selection = textSelection.copyWith(
        baseOffset: textSelection.start + myTextLength,
        extentOffset: textSelection.start + myTextLength,
      );
    }
    widget.onEmojiChanged?.call(myText);
  }

  /// If the user presses the Spacebar it will simply add a space
  void onActionSpaceBar() {
    if (widget.emojiController != null) {
      final text = widget.emojiController!.text;
      final textSelection = widget.emojiController!.selection;
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        ' ',
      );
      widget.emojiController!.text = newText;
      widget.emojiController!.selection = textSelection.copyWith(
        baseOffset: textSelection.start + 1,
        extentOffset: textSelection.start + 1,
      );
    }
  }

  /// If the user presses the backspace located on the bottom bar it should
  /// remove the previous emoji (or character) based on where the cursor is
  /// at that moment.
  /// Using the skipLast(1) functionality we determine which that is and
  /// remove it.
  /// First we check if a selection is made, if that's the case we remove
  /// that selection
  /// if the user has the cursor in the beginning or nothing is in the
  /// Textfield nothing happens
  void onActionBackspace() {
    if (widget.emojiController != null) {
      final text = widget.emojiController!.text;
      final textSelection = widget.emojiController!.selection;
      final selectionLength = textSelection.end - textSelection.start;
      if (selectionLength > 0) {
        final newText = text.replaceRange(
          textSelection.start,
          textSelection.end,
          '',
        );
        widget.emojiController!.text = newText;
        widget.emojiController!.selection = textSelection.copyWith(
          baseOffset: textSelection.start,
          extentOffset: textSelection.start,
        );
        return;
      }

      if (textSelection.start == 0) {
        if (text.isEmpty) {
          return;
        } else {
          // Eagerly selects all but the last count characters
          final String finalCharacter = text.characters.skipLast(1).string;
          // So if the result is empty there was only 1 character
          if (finalCharacter == '') {
            // If there was only 1 character we remove that one.
            widget.emojiController!.text = '';
            widget.emojiController!.selection = textSelection.copyWith(
              baseOffset: 0,
              extentOffset: 0,
            );
            return;
          }
        }
      }

      final String firstSection = text.substring(0, textSelection.start);
      final String newFirstSection = firstSection.characters.skipLast(1).string;
      final offset = firstSection.length - newFirstSection.length;
      final newStart = textSelection.start - offset;
      final newEnd = textSelection.start;
      final newText = text.replaceRange(
        newStart,
        newEnd,
        '',
      );
      widget.emojiController!.text = newText;
      widget.emojiController!.selection = textSelection.copyWith(
        baseOffset: newStart,
        extentOffset: newStart,
      );
    }
  }

  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  void pressedBackSearch() {
    if (searchMode) {
      // Hide the keyboard
      FocusManager.instance.primaryFocus?.unfocus();
      searchMode = false;
      if (widget.emojiKeyboardAnimationDuration == null) {
        setState(() {});
      } else {
        Future.delayed(widget.emojiKeyboardAnimationDuration!, () {
          setState(() {});
        });
      }
    }
  }

  Color getKeyboardColour() {
    return darkMode ? const Color(0xff373737) : const Color(0xffc5c5c5);
  }

  double getHeight() {
    if (widget.showEmojiKeyboard && !searchMode) {
      if (isPortrait()) {
        return emojiKeyboardHeight;
      } else {
        return (emojiKeyboardHeight / 3) * 2;
      }
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!searchMode)
          AnimatedContainer(
            duration: widget.emojiKeyboardAnimationDuration ?? Duration.zero,
            height: getHeight(),
            color: getKeyboardColour(),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CategoryBar(
                        key: categoryBarStateKey,
                        categoryHandler: categoryHandler,
                        darkMode: darkMode,
                      ),
                      EmojiPage(
                        key: emojiPageStateKey,
                        emojiKeyboardHeight: getHeight(),
                        emojiScrollShowBottomBar: emojiScrollShowBottomBar,
                        insertText: insertText,
                        recent: recentEmojis,
                        switchedPage: switchedPage,
                      ),
                      BottomBar(
                        key: bottomBarStateKey,
                        onActionSpaceBar: onActionSpaceBar,
                        onActionBackspace: onActionBackspace,
                        emojiSearch: emojiSearch,
                        darkMode: darkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (searchMode)
          AnimatedContainer(
            duration: widget.emojiKeyboardAnimationDuration ?? Duration.zero,
            height: widget.showEmojiKeyboard && searchMode
                ? isPortrait()
                    ? (MediaQuery.of(context).size.width / 8) +
                        48 +
                        MediaQuery.of(context).padding.bottom
                    : 50 + 48 + MediaQuery.of(context).padding.bottom
                : 0,
            color: getKeyboardColour(),
            child: Column(
              children: [
                SizedBox(
                  height: isPortrait()
                      ? (MediaQuery.of(context).size.width / 8)
                      : 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: searchedEmojis.length,
                    itemBuilder: (context, index) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xff898989),
                          onTap: () {
                            insertTextSearch(searchedEmojis[index]);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                searchedEmojis[index],
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.grey.shade600,
                      onPressed: pressedBackSearch,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextFormField(
                          focusNode: focusSearchEmoji,
                          onChanged: updateEmojiSearch,
                          style: TextStyle(
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          )
      ],
    );
  }
}
