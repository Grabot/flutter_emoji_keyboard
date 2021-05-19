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

/// This is the emoji page. This holds all the emoji grids.
class EmojiPage extends StatefulWidget {
  EmojiPage(
      {Key? key,
      required this.emojiKeyboardHeight,
      required this.bromotionController,
      required this.emojiScrollShowBottomBar,
      required this.insertText,
      required this.switchedPage,
      required this.recent})
      : super(key: key);

  final double emojiKeyboardHeight;
  final TextEditingController bromotionController;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String) insertText;
  final Function(int) switchedPage;
  final List<String> recent;

  @override
  EmojiPageState createState() => EmojiPageState();
}

/// The Emoji page will be a scrollview holding 9 gridviews.
/// Each gridview will correspond to a category.
/// Here all the emojis are loaded for each category and passed on to their
/// corresponding category.
/// For Android, a check is added te remove any emoji which the api version
/// for that phone cannot show that emoji.
class EmojiPageState extends State<EmojiPage> {
  static const platform =
      const MethodChannel("nl.emojikeyboard.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  final GlobalKey<EmojiGridState> emojiGridStateKey =
      GlobalKey<EmojiGridState>();

  List smileys = [];
  List animals = [];
  List foods = [];
  List activities = [];
  List travel = [];
  List objects = [];
  List symbols = [];
  List flags = [];

  PageController pageController = new PageController(initialPage: 1);
  TextEditingController? bromotionController;

  bool showBottomBar = true;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;

    isAvailable();

    pageController.addListener(() => pageScrollListener());

    super.initState();
  }

  /// We load the emojis from the emoji dart files we have included in the
  /// package.
  /// Here we also store the name given to the emoji. Since we don't show it
  /// we have this simple function which retrieves only the emojis of these
  /// lists.
  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  /// When new emojis are announced Android has to update their platform to
  /// be able to show these emojis. Since with Android a lot of users have
  /// an older version of Android because they have an older phone or for other
  /// reasons we can't always show all the emojis.
  /// This function filters the emojis which cannot be shown by sending a call
  /// to the Android channel to see which it can and can't draw.
  /// For Iphone the user is forced to update if an update is out so we don't
  /// need to do a similar call for Iphones.
  isAvailable() {
    if (Platform.isAndroid) {
      Future.wait([
        getAvailableSmileys(),
        getAvailableAnimals(),
        getAvailableFoods(),
        getAvailableActivities(),
        getAvailableTravels(),
        getAvailableObjects(),
        getAvailableSymbols(),
        getAvailableFlags()
      ]).then((var value) {
        emojiGridStateKey.currentState!.forceUpdate(this.smileys);
      });
    } else {
      setState(() {
        this.smileys = getEmojis(smileysList);
        this.animals = getEmojis(animalsList);
        this.foods = getEmojis(foodsList);
        this.activities = getEmojis(activitiesList);
        this.travel = getEmojis(travelList);
        this.objects = getEmojis(objectsList);
        this.symbols = getEmojis(symbolsList);
        this.flags = getEmojis(flagsList);
      });
    }
  }

  /// Here we load the smiley emojis and filter out the ones we can't show
  Future getAvailableSmileys() async {
    this.smileys = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(smileysList)});
  }

  /// Here we load the animal emojis and filter out the ones we can't show
  Future getAvailableAnimals() async {
    this.animals = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(animalsList)});
  }

  /// Here we load the food emojis and filter out the ones we can't show
  Future getAvailableFoods() async {
    this.foods = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(foodsList)});
  }

  /// Here we load the activities emojis and filter out the ones we can't show
  Future getAvailableActivities() async {
    this.activities = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(activitiesList)});
  }

  /// Here we load the travels emojis and filter out the ones we can't show
  Future getAvailableTravels() async {
    this.travel = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(travelList)});
  }

  /// Here we load the object emojis and filter out the ones we can't show
  Future getAvailableObjects() async {
    this.objects = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(objectsList)});
  }

  /// Here we load the symbols emojis and filter out the ones we can't show
  Future getAvailableSymbols() async {
    this.symbols = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(symbolsList)});
  }

  /// Here we load the flags emojis and filter out the ones we can't show
  Future getAvailableFlags() async {
    this.flags = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojis(flagsList)});
  }

  /// If the user presses a category key it will update the category bar and
  /// send a trigger to this function. This will set the page to be the same
  /// as the category that the user has just selected.
  void navigateCategory(int categoryNumber) {
    pageController.animateToPage(categoryNumber,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  /// If the user scrolls left or right the page is updated and a trigger is
  /// send to the category bar to set the correct category.
  /// It only sets this trigger if it detects any scrolling.
  pageScrollListener() {
    if (pageController.hasClients) {
      if (pageController.position.userScrollDirection ==
              ScrollDirection.reverse ||
          pageController.position.userScrollDirection ==
              ScrollDirection.forward) {
        widget.switchedPage(pageController.page!.round());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Here we build the emoji page. We have 8 categories and a recent tab for a total of 9 pages
    return Container(
      height: widget.emojiKeyboardHeight - 50,
      child: PageView(controller: pageController, children: [
        EmojiGrid(
            emojis: widget.recent,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: smileys,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText,
            key: emojiGridStateKey),
        EmojiGrid(
            emojis: animals,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: foods,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: activities,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: travel,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: objects,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: symbols,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText),
        EmojiGrid(
            emojis: flags,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            insertText: widget.insertText)
      ]),
    );
  }
}
