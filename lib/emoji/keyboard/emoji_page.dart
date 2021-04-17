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
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emoji_grid.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.bromotionController,
    this.emojiScrollShowBottomBar
  }): super(key: key);

  final TextEditingController bromotionController;
  final Function(bool) emojiScrollShowBottomBar;

  @override
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
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
        setState(() {
          recent = recentUsed;
        });
      }
    });
    isAvailable();

    this.bromotionController = widget.bromotionController;

    pageController = new PageController();

    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: PageView(
        controller: pageController,
        children: [
          EmojiGrid(
              emojis: recent,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: smileys,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: animals,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: foods,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: activities,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: travel,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: objects,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: symbols,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          ),
          EmojiGrid(
              emojis: flags,
              emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
          )
        ]
      ),
    );
  }

}
