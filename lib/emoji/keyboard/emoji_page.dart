import 'dart:io';

import 'package:emoji_keyboard/emoji/activities.dart';
import 'package:emoji_keyboard/emoji/animals.dart';
import 'package:emoji_keyboard/emoji/flags.dart';
import 'package:emoji_keyboard/emoji/foods.dart';
import 'package:emoji_keyboard/emoji/objects.dart';
import 'package:emoji_keyboard/emoji/smileys.dart';
import 'package:emoji_keyboard/emoji/symbols.dart';
import 'package:emoji_keyboard/emoji/travel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emoji_grid.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.emojiKeyboardHeight,
    this.bromotionController,
    this.emojiScrollShowBottomBar,
    this.switchedPage
  }): super(key: key);

  final double emojiKeyboardHeight;
  final TextEditingController bromotionController;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(int) switchedPage;

  @override
  EmojiPageState createState() => EmojiPageState();
}

class EmojiPageState extends State<EmojiPage> {
  static const platform = const MethodChannel("nl.emojikeyboard.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  List<String> recent;
  List smileys;
  List animals;
  List foods;
  List activities;
  List travel;
  List objects;
  List symbols;
  List flags;

  PageController pageController;
  TextEditingController bromotionController;

  void textInputHandler(String text) => print(text);

  bool showBottomBar = true;

  @override
  void initState() {
    this.smileys = getEmojis(smileysList);
    this.animals = getEmojis(animalsList);
    this.foods = getEmojis(foodsList);
    this.activities = getEmojis(activitiesList);
    this.travel = getEmojis(travelList);
    this.objects = getEmojis(objectsList);
    this.symbols = getEmojis(symbolsList);
    this.flags = getEmojis(flagsList);

    recent = [];
    getRecentEmoji().then((value) {
      List<String> recentUsed = [];
      if (value != null && value != []) {
        for (var val in value) {
          recentUsed.add(val.toString());
        }
        pageController.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
        widget.switchedPage(0);
        setState(() {
          recent = recentUsed;
        });
      }
    });
    isAvailable();

    this.bromotionController = widget.bromotionController;

    pageController = new PageController(initialPage: 1);
    pageController.addListener(() => pageScrollListener());

    super.initState();
  }

  void addRecentEmoji(String emoji) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> currentRecent = preferences.getStringList(recentEmojisKey);
    if (currentRecent == null || currentRecent == []) {
      print("creating an empthy list for recent");
      currentRecent = [];
    } else {
      // If the emoji is already in the list, then remove it so it is added in the front.
      currentRecent.removeWhere((item) => item == emoji);
    }
    print("setting a new recent emoji $emoji");
    currentRecent.insert(0, emoji.toString());
    preferences.setStringList(recentEmojisKey, recent);
    setState(() {
      recent = currentRecent;
    });
  }

  Future getRecentEmoji() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    return recent;
  }

  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  isAvailable() {
    if (Platform.isAndroid) {
      Future.wait([getAvailableSmileys(), getAvailableAnimals(),
        getAvailableFoods(), getAvailableActivities(), getAvailableTravels(),
        getAvailableObjects(), getAvailableSymbols(), getAvailableFlags()])
          .then((var value) {
        setState(() {
          print("emojis loaded");
        });
      });
    }
  }

  Future getAvailableSmileys() async {
    this.smileys = await platform.invokeMethod(
        "isAvailable", {"emojis": this.smileys});
  }

  Future getAvailableAnimals() async {
    this.animals = await platform.invokeMethod(
        "isAvailable", {"emojis": this.animals});
  }

  Future getAvailableFoods() async {
    this.foods = await platform.invokeMethod(
        "isAvailable", {"emojis": this.foods});
  }

  Future getAvailableActivities() async {
    this.activities = await platform.invokeMethod(
        "isAvailable", {"emojis": this.activities});
  }

  Future getAvailableTravels() async {
    this.travel = await platform.invokeMethod(
        "isAvailable", {"emojis": this.travel});
  }

  Future getAvailableObjects() async {
    this.objects = await platform.invokeMethod(
        "isAvailable", {"emojis": this.objects});
  }

  Future getAvailableSymbols() async {
    this.symbols = await platform.invokeMethod(
        "isAvailable", {"emojis": this.symbols});
  }

  Future getAvailableFlags() async {
    this.flags = await platform.invokeMethod(
        "isAvailable", {"emojis": this.flags});
  }

  void navigateCategory(int categoryNumber) {
    pageController.animateToPage(categoryNumber, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  pageScrollListener() {
    if (pageController.hasClients) {
      if (pageController.position.userScrollDirection == ScrollDirection.reverse || pageController.position.userScrollDirection == ScrollDirection.forward) {
        widget.switchedPage(pageController.page.round());
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.emojiKeyboardHeight-50,
      child: PageView(
        controller: pageController,
        children: [
          EmojiGrid(
              emojis: recent,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: smileys,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: animals,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: foods,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: activities,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: travel,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: objects,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: symbols,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          ),
          EmojiGrid(
              emojis: flags,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: insertText
          )
        ]
      ),
    );
  }

}
