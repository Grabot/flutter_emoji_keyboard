import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'emoji/component/component.dart';
import 'emoji_grid.dart';
import 'emoji/activities.dart';
import 'emoji/animals.dart';
import 'emoji/flags.dart';
import 'emoji/foods.dart';
import 'emoji/objects.dart';
import 'emoji/smileys.dart';
import 'emoji/symbols.dart';
import 'emoji/travel.dart';

/// This is the emoji page. This holds all the emoji grids.
class EmojiPage extends StatefulWidget {
  const EmojiPage(
      {Key? key,
      required this.emojiKeyboardHeight,
      required this.emojiController,
      required this.emojiScrollShowBottomBar,
      required this.insertText,
      required this.recent,
      required this.switchedPage})
      : super(key: key);

  final double emojiKeyboardHeight;
  final TextEditingController emojiController;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String, int) insertText;
  final List<String> recent;
  final Function(int) switchedPage;

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
  static const platform = MethodChannel("nl.emojikeyboard.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  final GlobalKey<EmojiGridState> smileyStateKey = GlobalKey<EmojiGridState>();
  final GlobalKey<EmojiGridState> recentStateKey = GlobalKey<EmojiGridState>();

  List smileys = [];
  List animals = [];
  List foods = [];
  List activities = [];
  List travel = [];
  List objects = [];
  List symbols = [];
  List flags = [];

  List<bool> availableSmileys = [];

  PageController pageController = PageController(initialPage: 1);
  TextEditingController? emojiController;

  bool showBottomBar = true;

  @override
  void initState() {
    emojiController = widget.emojiController;

    isAvailable();

    pageController = PageController(initialPage: 1);
    pageController.addListener(pageScrollListener);

    super.initState();
  }

  @override
  void dispose() {
    pageController.removeListener(pageScrollListener);
    super.dispose();
  }

  /// We check the component availability of the smiley category.
  /// We do that here because we don't want to constantly check it every time
  /// the user opens the category.
  /// We keep a boolean array in memory here of which emojis have components.
  checkComponentsSmileys(List smileyList) async {
    availableSmileys = List.filled(smileyList.length, false, growable: false);
    for (int i = 0; i < smileyList.length; i++) {
      if (componentsMap.containsKey(smileyList[i])) {
        if (Platform.isAndroid) {
          List<String> components = [];
          // We are checking if the components are able to be drawn by Android.
          components.addAll(componentsMap[smileyList[i]]);
          List<Object?> availableEmojis = await platform
              .invokeMethod("isAvailable", {"emojis": components});
          // If none can be drawn than we don't set availability
          if (availableEmojis.isNotEmpty) {
            availableSmileys[i] = true;
          }
        } else {
          availableSmileys[i] = true;
        }
      }
    }
  }

  /// We load the emojis from the emoji dart files we have included in the
  /// package.
  /// Here we also store the name given to the emoji. Since we don't show it
  /// we have this simple function which retrieves only the emojis of these
  /// lists.
  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (var emotion in emojiList) {
      onlyEmoji.add(emotion);
    }
    return onlyEmoji;
  }

  /// This function gets the emoji String from the original list
  /// which includes description and keywords, the emoji is the first entry.
  List<String> getEmojisString(emojiList) {
    List<String> onlyEmoji = [];
    for (var emoji in emojiList) {
      onlyEmoji.add(emoji[0]);
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
        if (smileyStateKey.currentState != null) {
          smileyStateKey.currentState!.forceUpdate(smileys, availableSmileys);
        }
        if (recentStateKey.currentState != null) {
          // We know that all the emojis in 'recent' have been used before.
          // So we generate a list of 'true' values for the 'recent' emojis.
          List<bool> recentAvailable =
              List.filled(widget.recent.length, true, growable: false);
          recentStateKey.currentState!
              .forceUpdate(widget.recent, recentAvailable);
        }
      });
    } else {
      setState(() {
        smileys = getEmojisString(smileysList);
        animals = getEmojisString(animalsList);
        foods = getEmojisString(foodsList);
        activities = getEmojisString(activitiesList);
        travel = getEmojisString(travelList);
        objects = getEmojisString(objectsList);
        symbols = getEmojisString(symbolsList);
        flags = getEmojisString(flagsList);
        checkComponentsSmileys(smileys);
      });
    }
  }

  /// Here we load the smiley emojis and filter out the ones we can't show
  Future getAvailableSmileys() async {
    smileys = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(smileysList)});
    await checkComponentsSmileys(smileys);
  }

  /// Here we load the animal emojis and filter out the ones we can't show
  Future getAvailableAnimals() async {
    animals = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(animalsList)});
  }

  /// Here we load the food emojis and filter out the ones we can't show
  Future getAvailableFoods() async {
    foods = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(foodsList)});
  }

  /// Here we load the activities emojis and filter out the ones we can't show
  Future getAvailableActivities() async {
    activities = await platform.invokeMethod(
        "isAvailable", {"emojis": getEmojisString(activitiesList)});
  }

  /// Here we load the travels emojis and filter out the ones we can't show
  Future getAvailableTravels() async {
    travel = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(travelList)});
  }

  /// Here we load the object emojis and filter out the ones we can't show
  Future getAvailableObjects() async {
    objects = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(objectsList)});
  }

  /// Here we load the symbols emojis and filter out the ones we can't show
  Future getAvailableSymbols() async {
    symbols = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(symbolsList)});
  }

  /// Here we load the flags emojis and filter out the ones we can't show
  Future getAvailableFlags() async {
    flags = await platform
        .invokeMethod("isAvailable", {"emojis": getEmojisString(flagsList)});
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
    double emojiSize = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      height: widget.emojiKeyboardHeight - 50,
      child: PageView(controller: pageController, children: [
        EmojiGrid(
            key: recentStateKey,
            emojis: widget.recent,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 0,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            key: smileyStateKey,
            emojis: smileys,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 1,
            insertText: widget.insertText,
            emojiSize: emojiSize,
            available: availableSmileys),
        EmojiGrid(
            emojis: animals,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 2,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: foods,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 3,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: activities,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 4,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: travel,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 5,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: objects,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 6,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: symbols,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 7,
            insertText: widget.insertText,
            emojiSize: emojiSize),
        EmojiGrid(
            emojis: flags,
            emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar,
            categoryIndicator: 8,
            insertText: widget.insertText,
            emojiSize: emojiSize)
      ]),
    );
  }
}
