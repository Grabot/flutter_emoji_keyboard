import 'dart:io';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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

  backButtonFunctionality() {
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
        body: Stack(children: [
          Container(
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
          Align(
            alignment: Alignment.bottomCenter,
            child: EmojiKeyboard(
                emojiController: controller,
                emojiKeyboardHeight: 440,
                showEmojiKeyboard: showEmojiKeyboard,
                darkMode: true),
          ),
        ]),
      ),
    );
  }
}
