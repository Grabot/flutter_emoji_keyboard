import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'emoji_key.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.emojis,
    this.bromotionController
  }): super(key: key);

  final List emojis;
  final TextEditingController bromotionController;

  @override
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
  static const platform = const MethodChannel("nl.brocast.emoji/available");

  List emojis;

  ScrollController scrollController;
  TextEditingController bromotionController;

  void textInputHandler(String text) => print(text);

  bool showBottomBar = true;

  @override
  void initState() {
    this.emojis = widget.emojis;

    this.bromotionController = widget.bromotionController;

    scrollController = new ScrollController();

    super.initState();
  }

  isAvailable() {
    if (Platform.isAndroid) {
      Future.wait([getAvailableEmojis()])
          .then((var value) {
        setState(() {
          print("emojis loaded");
        });
      });
    }
  }

  Future getAvailableEmojis() async {
    this.emojis = await platform.invokeMethod(
        "isAvailable", {"emojis": this.emojis});
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: emojis.length,
        itemBuilder: (BuildContext ctx, index) {
        return TextButton(
            child: Text(emojis[index])
        );
      }
    );
  }

}
