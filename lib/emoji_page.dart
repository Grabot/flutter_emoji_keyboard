import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'emoji_grid.dart';
import 'emojis/activities.dart';
import 'emojis/animals.dart';
import 'emojis/flags.dart';
import 'emojis/foods.dart';
import 'emojis/objects.dart';
import 'emojis/smileys.dart';
import 'emojis/symbols.dart';
import 'emojis/travel.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.emojiKeyboardHeight,
    this.bromotionController,
    this.emojiScrollShowBottomBar,
    this.insertText,
    this.switchedPage,
    this.recent
  }): super(key: key);

  final double emojiKeyboardHeight;
  final TextEditingController bromotionController;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String) insertText;
  final Function(int) switchedPage;
  final List<String> recent;

  @override
  EmojiPageState createState() => EmojiPageState();
}

class EmojiPageState extends State<EmojiPage> {
  static const platform = const MethodChannel("nl.emojikeyboard.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  // List<String> recent;
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

    isAvailable();

    this.bromotionController = widget.bromotionController;

    pageController = new PageController(initialPage: 1);
    pageController.addListener(() => pageScrollListener());

    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.emojiKeyboardHeight-50,
      child: PageView(
        controller: pageController,
        children: [
          EmojiGrid(
              emojis: widget.recent,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: smileys,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: animals,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: foods,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: activities,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: travel,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: objects,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: symbols,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          ),
          EmojiGrid(
              emojis: flags,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
              insertText: widget.insertText
          )
        ]
      ),
    );
  }

}
