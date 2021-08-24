import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Keyboard',
      debugShowCheckedModeBanner: false,
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

  bool showEmojiKeyboard;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    showEmojiKeyboard = false;
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      return false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
          children: [
            Container(
              color: Colors.white,
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
                bromotionController: controller,
                emojiKeyboardHeight: 420,
                showEmojiKeyboard: showEmojiKeyboard,
                darkMode: true
              ),
            ),
          ]
      ),
    );
  }
}
