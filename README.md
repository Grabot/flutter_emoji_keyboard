# Flutter Emoji Keyboard

[![pub package](https://img.shields.io/pub/v/emoji_keyboard_flutter.svg)](https://pub.dartlang.org/packages/emoji_keyboard_flutter)

A Flutter package that provides a keyboard where you can only type with emojis!

It's a keyboard the way you expect it and more! But with less letters and only emojis.


<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/34c7a4bab33d8d4c9004d83402b432baa42ffcf4/example_images/Screenshot_1649252768.png" alt="Alt Text" width="200">
<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/34c7a4bab33d8d4c9004d83402b432baa42ffcf4/example_images/Screenshot_1649252939.png" alt="Alt Text" width="200">
<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/34c7a4bab33d8d4c9004d83402b432baa42ffcf4/example_images/Screenshot_1649253604.png" alt="Alt Text" width="200">
<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/34c7a4bab33d8d4c9004d83402b432baa42ffcf4/example_images/Screenshot_1649253641.png" alt="Alt Text" width="200">



## Key features

Smooth and intuitive keyboard layout with all the emojis up to unicode 16.0 available in separate 8 categories with a 'recent chosen' tab.

You can easily switch between categories by swiping or selecting the category from the top bar.

Emojis that cannot be displayed are filtered out (only for Android)

You can even search for your emoji by using the search functionality available in the bottom bar.

From this keyboard you can also delete an emoji from the position of the cursor or add a space from the bottom bar.

Determine the height of the keyboard and show or hide it using a simple variable

The emojis have an indicator which shows if you can add a skin component to them. If this is the case you can add one by long pressing the emoji and selecting a skin component from the resulting popup window.

Change the default light setting to dark mode

<img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/34c7a4bab33d8d4c9004d83402b432baa42ffcf4/example_images/Screenshot_1649253828.png" alt="Alt Text" width="250">


## Usage
To use this plugin, add `emoji_keyboard_flutter` as dependency in your pubspec.yaml file.

## Sample Usage
```
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Emoji Keyboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

......

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(

          .....

            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  emojiController: controller,
                  emojiKeyboardHeight: 400,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: true),
            ),
          ]
      ),
    );
  }
}


```
See the `example` directory for the complete sample app.
