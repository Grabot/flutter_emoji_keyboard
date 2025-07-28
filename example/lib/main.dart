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
            width: MediaQuery.of(context).size.width,
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
                  child: ListView(
                    reverse: true,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(
                            bottom: 12.0, left: 8, right: 8, top: 12),
                        child: TextFormField(
                          onTap: onTapEmojiField,
                          controller: controller,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          readOnly: true,
                          showCursor: true,
                        ),
                      ),
                      messageWidget(1,
                          'Or press the Textfield below to start typing with the emoji keyboard!'),
                      messageWidget(0,
                          'This is an example message. Long press to do an emoji reaction on this message!'),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                    emojiController:
                    emojiReactionIndex == -1 ? controller : null,
                    onEmojiChanged: onActionEmojiChanged,
                    showEmojiKeyboard: showEmojiKeyboard,
                    emojiKeyboardHeight: 440, // optional defaults to 350
                    darkMode: darkMode, // optional defaults to false
                    emojiKeyboardAnimationDuration: const Duration(
                        milliseconds: 400), // optional defaults to null
                  ),
                ),
              ],
            ),
            EmojiKeyboardPopup(
              position: emojiPopupPosition,
              onAction: handleEmojiPopupAction,
              showEmojiPopup: showEmojiPopup,
              darkMode: darkMode, // optional defaults to false
              popupWidth: 350, // optional defaults to 350
              highlightedEmoji: emojiReactionIndex == -1
                  ? null
                  : emojiReactions[
              emojiReactionIndex], // optional defaults to null
              emojiPopupAnimationDuration: const Duration(
                  milliseconds: 400), // optional defaults to null
            ),
          ],
        ),
      ),
    );
  }
}