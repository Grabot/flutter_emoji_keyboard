import 'package:emoji_keyboard/emoji_keyboard.dart';


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
                  emojiKeyboardHeight: 350,
                  showEmojiKeyboard: showEmojiKeyboard
              ),
            ),
          ]
      ),
    );
  }
}
