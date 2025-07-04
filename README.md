# Flutter Emoji Keyboard

[![pub package](https://img.shields.io/pub/v/emoji_keyboard_flutter.svg)](https://pub.dartlang.org/packages/emoji_keyboard_flutter)

A Flutter package that provides a keyboard where you can only type with emojis!

It's a keyboard the way you expect it and more! But with less letters and only emojis.

|Emoji selection| Skin selection                                                                                                                                                                                         | Search option                                                                                                                                                                                          |
|---|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|<img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_selection.png?raw=true" alt="Emoji selection" width="90%">| <img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_skin.png?raw=true" alt="Skin selection" width="91%"> | <img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_search.png?raw=true" alt="Search option" width="100%"> |


| Emoji popup widget                                                                                                                                                                                       | Recent emojis                                                                                                                                                                                        | Dark or Light mode                                                                                                                                                                                     |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_popup.png?raw=true" alt="Emoji selection" width="90%"> | <img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_recent.png?raw=true" alt="Skin selection" width="91%"> | <img src="https://github.com/Grabot/flutter_emoji_keyboard/blob/b582d2609d3ec698969e301325e4cbdaf8472e74/example/assets/images/emoji_keyboard_darkmode.png?raw=true" alt="Search option" width="100%"> |


## Key features

Smooth and intuitive keyboard layout with all the emojis up to unicode 16.0 available in separate 8 categories with a 'recent chosen' tab.

You can easily switch between categories by swiping or selecting the category from the top bar.

Emojis that cannot be displayed are filtered out (only for Android)

You can even search for your emoji by using the search functionality available in the bottom bar.

From this keyboard you can also delete an emoji from the position of the cursor or add a space from the bottom bar.

Determine the height of the keyboard and show or hide it using a simple variable

The emojis have an indicator which shows if you can add a skin component to them. If this is the case you can add one by long pressing the emoji and selecting a skin component from the resulting popup window.

Change the default light setting to dark mode

Instead of the keyboard you can also use the quick emoji popup widget. Select one of the many quick reaction emojis or from your recent emojis. The widget has a "+" button that you can implement to open the regular emoji keyboard.

## Usage
To use this plugin, add `emoji_keyboard_flutter` as dependency in your pubspec.yaml file.

## Full Sample Usage
```
import 'dart:io';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Keyboard',
      home: MyHomePage(key: UniqueKey(), title: 'Emoji Keyboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool showEmojiKeyboard = false;
  final TextEditingController controller = TextEditingController();

  int emojiReactionIndex = -1;
  bool showEmojiPopup = false;
  Offset emojiPopupPosition = Offset.zero;
  List<String> emojiReactions = ['', ''];

  bool darkMode = false;

  void backButtonFunctionality() {
    if (emojiReactionIndex != -1) {
      emojiReactionIndex = -1;
    }
    if (showEmojiPopup) {
      setState(() {
        showEmojiPopup = false;
      });
      return;
    }
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return;
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void onTapEmojiField() {
    emojiReactionIndex = -1;
    if (showEmojiPopup) {
      setState(() {
        showEmojiPopup = false;
      });
    }
    if (!showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = true;
      });
    }
  }

  void onLongPressMessage(
      BuildContext context, LongPressStartDetails details, int messageIndex) {
    emojiReactionIndex = messageIndex;
    setState(() {
      showEmojiPopup = true;
      emojiPopupPosition = details.globalPosition;
    });
  }

  void handleEmojiPopupAction(EmojiPopupAction action) {
    showEmojiPopup = false;
    if (action is OutsideClicked) {
      emojiReactionIndex = -1;
    } else if (action is ButtonPressed) {
      showEmojiKeyboard = true;
    } else if (action is EmojiSelected) {
      final String newEmoji = action.emoji;
      if (emojiReactions[emojiReactionIndex] == newEmoji) {
        emojiReactions[emojiReactionIndex] = '';
      } else {
        emojiReactions[emojiReactionIndex] = action.emoji;
      }
      emojiReactionIndex = -1;
    }
    setState(() {});
  }

  void onActionEmojiChanged(String emoji) {
    if (emojiReactionIndex != -1) {
      emojiReactions[emojiReactionIndex] = emoji;
      emojiReactionIndex = -1;
      if (showEmojiKeyboard) {
        showEmojiKeyboard = false;
      }
      setState(() {});
    }
  }

  TextEditingController? getEmojiController() {
    if (emojiReactionIndex != -1) {
      return null;
    } else {
      return controller;
    }
  }

  Widget messageWidget(int messageIndex, String messageText) {
    return GestureDetector(
      onLongPressStart: (details) =>
          onLongPressMessage(context, details, messageIndex),
      child: Stack(
        children: [
          Container(
            color: emojiReactionIndex == messageIndex
                ? Colors.cyan[200]
                : Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: messageIndex == 0 ? Colors.green[200] : Colors.blue[200],
                borderRadius: BorderRadius.only(
                  topLeft: messageIndex == 0
                      ? const Radius.circular(30.0)
                      : Radius.zero,
                  topRight: messageIndex == 1
                      ? const Radius.circular(30.0)
                      : Radius.zero,
                  bottomLeft: const Radius.circular(30.0),
                  bottomRight: const Radius.circular(30.0),
                ),
              ),
              child: Text(
                messageText,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          if (emojiReactions[messageIndex] != '')
            Positioned(
              bottom: 0,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  emojiReactions[messageIndex],
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(),
                ),
                messageWidget(0,
                    'This is an example message. Long press to do an emoji reaction on this message!'),
                messageWidget(1,
                    'Or press the Textfield below to start typing with the emoji keyboard!'),
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(
                      bottom: 46.0, left: 8, right: 8, top: 12),
                  child: TextFormField(
                    onTap: onTapEmojiField,
                    controller: controller,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    readOnly: true,
                    showCursor: true,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                    emojiController: emojiReactionIndex == -1 ? controller : null,
                    onEmojiChanged: onActionEmojiChanged,
                    showEmojiKeyboard: showEmojiKeyboard,
                    emojiKeyboardHeight: 440, // optional defaults to 350
                    darkMode: darkMode, // optional defaults to false
                  ),
                ),
              ],
            ),
            if (showEmojiPopup)
              EmojiKeyboardPopup(
                position: emojiPopupPosition,
                onAction: handleEmojiPopupAction,
                darkMode: darkMode, // optional defaults to false
                popupWidth: 350, // optional defaults to 3/4 of the screen width
              ),
          ],
        ),
      ),
    );
  }
}
```
See the `example` directory for the complete sample app.
