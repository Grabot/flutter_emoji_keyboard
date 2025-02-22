# Flutter Emoji Keyboard

[![pub package](https://img.shields.io/pub/v/emoji_keyboard_flutter.svg)](https://pub.dartlang.org/packages/emoji_keyboard_flutter)

A Flutter package that provides a keyboard where you can only type with emojis!

It's a keyboard the way you expect it and more! But with less letters and only emojis.

|<div style="width:20%">Emoji selection</div>|<div style="width:20%">Skin selection</div>|<div style="width:20%">Search option</div>|<div style="width:20%">Recent emojis</div>|
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|<div style="width:20%">![random_emoji_selection.png](https://github.com/Grabot/flutter_emoji_keyboard/blob/b660c6c3fe9e089c243c062f2abec3d181515899/flutter_emoji_keyboard_screens/random_emoji_selection.png?raw=true)</div>|<div style="width:20%">![skin_selection.png](https://github.com/Grabot/flutter_emoji_keyboard/blob/b660c6c3fe9e089c243c062f2abec3d181515899/flutter_emoji_keyboard_screens/skin_selection.png?raw=true)</div>|<div style="width:20%">![search_options.png](https://github.com/Grabot/flutter_emoji_keyboard/blob/b660c6c3fe9e089c243c062f2abec3d181515899/flutter_emoji_keyboard_screens/search_options.png?raw=true)</div>|<div style="width:20%">![recent_page.png](https://github.com/Grabot/flutter_emoji_keyboard/blob/b660c6c3fe9e089c243c062f2abec3d181515899/flutter_emoji_keyboard_screens/recent_page.png?raw=true)</div>|


## Key features

Smooth and intuitive keyboard layout with all the emojis up to unicode 16.0 available in separate 8 categories with a 'recent chosen' tab.

You can easily switch between categories by swiping or selecting the category from the top bar.

Emojis that cannot be displayed are filtered out (only for Android)

You can even search for your emoji by using the search functionality available in the bottom bar.

From this keyboard you can also delete an emoji from the position of the cursor or add a space from the bottom bar.

Determine the height of the keyboard and show or hide it using a simple variable

The emojis have an indicator which shows if you can add a skin component to them. If this is the case you can add one by long pressing the emoji and selecting a skin component from the resulting popup window.

Change the default light setting to dark mode

<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/b660c6c3fe9e089c243c062f2abec3d181515899/flutter_emoji_keyboard_screens/dark_mode.png" alt="Alt Text" width="250">

## Usage
To use this plugin, add `emoji_keyboard_flutter` as dependency in your pubspec.yaml file.

## Full Sample Usage
```
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
```
See the `example` directory for the complete sample app.
