import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmojiGrid extends StatefulWidget {

  final List emojis;
  final Function(bool) emojiScrollShowBottomBar;
  final TextEditingController bromotionController;

  EmojiGrid({
    Key key,
    this.emojis,
    this.emojiScrollShowBottomBar,
    this.bromotionController,
  }) : super(key: key);

  @override
  _EmojiGridState createState() => _EmojiGridState();
}

class _EmojiGridState extends State<EmojiGrid> {
  static String recentEmojisKey = "recentEmojis";

  List emojis;
  ScrollController scrollController;
  TextEditingController bromotionController;

  @override
  void initState() {
    this.emojis = widget.emojis;
    this.bromotionController = widget.bromotionController;

    scrollController = new ScrollController();
    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  keyboardScrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        print("reached the bottom of the scrollview");
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.emojiScrollShowBottomBar(false);
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.emojiScrollShowBottomBar(true);
      }
    }
  }

  void insertText(String myText) {
    addRecentEmoji(myText);
    widget.emojiScrollShowBottomBar(true);
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void pressedEmoji(String emoji) {
    widget.emojiScrollShowBottomBar(true);
    addRecentEmoji(emoji);
    insertText(emoji);
  }

  void addRecentEmoji(String emoji) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    if (recent == null || recent == []) {
      recent = [];
    } else {
      // If the emoji is already in the list, then remove it so it is added in the front.
      recent.removeWhere((item) => item == emoji);
    }
    setState(() {
      recent.insert(0, emoji.toString());
      preferences.setStringList(recentEmojisKey, recent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: emojis.length,
        itemBuilder: (BuildContext ctx, index) {
          return TextButton(
              onPressed: () {
                pressedEmoji(emojis[index]);
              },
              child: Text(
                  emojis[index],
                  style: TextStyle(
                      fontSize: 25
                  )
              )
          );
        }
    );
  }
}
