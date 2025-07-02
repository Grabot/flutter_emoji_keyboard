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
  bool showEmojiPopup = false;
  Offset popupPosition = Offset.zero;

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
  }

  void onTapEmojiField() {
    if (!showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = true;
      });
    }
  }

  void onLongPressMessage(BuildContext context, LongPressStartDetails details) {
    setState(() {
      showEmojiPopup = true;
      popupPosition = details.globalPosition;
    });
  }

  void closeEmojiPopup() {
    setState(() {
      showEmojiPopup = false;
    });
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
                GestureDetector(
                  onLongPressStart: (details) => onLongPressMessage(context, details),
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                      color: Colors.green[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                      'This is an example message. Long press to do an emoji reaction on this message!',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
                GestureDetector(
                  onLongPressStart: (details) => onLongPressMessage(context, details),
              child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Or press the Textfield below to start typing with the emoji keyboard!',
                      style: TextStyle(fontSize: 16.0),
                    ),
                ),
              ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 76.0),
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(6),
                    child: TextFormField(
                      onTap: () {
                        onTapEmojiField();
                      },
                      controller: controller,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      readOnly: true,
                      showCursor: true,
              ),
            ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                    emojiController: controller,
                    emojiKeyboardHeight: 440,
                    showEmojiKeyboard: showEmojiKeyboard,
                    darkMode: true,
        ),
      ),
              ],
            ),
            if (showEmojiPopup)
              EmojiKeyboardPopup(
                position: popupPosition,
                onClose: closeEmojiPopup,
                darkMode: true,
              ),
          ],
        ),
      ),
    );
  }
}
