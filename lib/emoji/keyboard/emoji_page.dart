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
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: (emojis.length/8).ceil(),
      itemBuilder: (BuildContext cont, int index) {
        return new Row(
            children: [
              (index*8) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index * 8]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),// make it square),
              (index*8+1) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+1]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+2) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+2]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+3) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+3]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+4) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+4]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+5) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+5]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+6) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+6]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+7) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+7]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
            ]
        );
      },
    );
  }
}
