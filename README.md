# Flutter Emoji Keyboard

[![pub package](https://img.shields.io/pub/v/emoji_keyboard_flutter.svg)](https://pub.dartlang.org/packages/emoji_keyboard_flutter)

A Flutter package that provides keyboard where you can only type with emojis!

It's a keyboard the way you expect it and more! But with less letters and only emojis


<a href="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415098.png"><img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415098.png" width="200"></a>
<a href="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415191.png"><img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415191.png" width="200"></a>
<a href="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1628774419.png"><img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1628774419.png" width="200"></a>



## Key features

Smooth and intuitive keyboard layout with over 1800 emojis in 8 categories with an added 'recent chosen' tab.

You can easily switch between categories by swiping or selecting the category from the top bar.

Emojis that cannot be displayed are filtered out (only for Android)

You can even search for your emoji by using the search functionality available in the bottom bar.

From this keyboard you can also delete an emoji from the position of the cursor or add a space from the bottom bar.

Determine the height of the keyboard and show or hide it using a simple variable

Change the default light setting to dark mode

<a href="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415774.png"><img src="https://raw.githubusercontent.com/Grabot/flutter_emoji_keyboard/main/example_images/Screenshot_1621415774.png" width="200"></a>


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
                bromotionController: controller,
                emojiKeyboardHeight: 420,
                showEmojiKeyboard: true,
                darkMode: true
              ),
            ),
          ]
      ),
    );
  }
}


```
See the `example` directory for the complete sample app.
