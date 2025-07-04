import 'dart:ui';

import 'package:emoji_keyboard_flutter/src/emoji/component/component.dart';
import 'package:emoji_keyboard_flutter/src/util/popup_menu_override.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// This is the Grid which will hold all the emojis
class EmojiGrid extends StatefulWidget {
  final List<String> emojis;
  final void Function(bool) emojiScrollShowBottomBar;
  final void Function(String, int) insertText;
  final int categoryIndicator;
  final double emojiSize;
  final List<bool>? available;

  const EmojiGrid({
    Key? key,
    required this.emojis,
    required this.emojiScrollShowBottomBar,
    required this.categoryIndicator,
    required this.insertText,
    required this.emojiSize,
    this.available,
  }) : super(key: key);

  @override
  EmojiGridState createState() => EmojiGridState();
}

/// The grid will consist of a listview.
/// There are 9 separate listviews, each corresponding to a category.
/// For each category all the emojis are shown in this listview
/// A gridview.builder is used for performance. So not all the emojis have
/// to be loaded immediately but are loaded if the user scrolls.
class EmojiGridState extends State<EmojiGrid> {
  List<String>? emojis;
  ScrollController scrollController = ScrollController();
  ScrollController scrollPopupController = ScrollController();

  static const platform = MethodChannel("nl.emojikeyboard.emoji/available");

  List<bool> available = [];

  NavigatorState? navigator;
  String barrierLabel = "";
  CapturedThemes? capturedThemes;

  @override
  void initState() {
    emojis = widget.emojis;
    if (widget.available != null) {
      available = widget.available!;
    }

    scrollController.addListener(keyboardScrollListener);

    // Wait until the widget is loaded and then initialize the navigator
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      navigator = Navigator.of(context, rootNavigator: false);
      barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
      capturedThemes = InheritedTheme.capture(from: context, to: navigator!.context);
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(keyboardScrollListener);
    scrollController.dispose();
    scrollPopupController.dispose();
    super.dispose();
  }

  /// If the user scroll in the emoji we keep track of when the direction
  /// changes.
  /// If the user scrolls down a trigger is send to the bottom bar
  /// to hide the bottom bar if it was visible.
  /// If the user scrolls back up a trigger is send again to show the
  /// bottom bar if it was hidden
  void keyboardScrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        widget.emojiScrollShowBottomBar(false);
      }
      if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        widget.emojiScrollShowBottomBar(true);
      }
    }
  }

  /// If an emoji is pressed in the grid this function is called with the
  /// unicode of the emoji that is pressed.
  /// Here it sends a trigger to the "insertText" function in the EmojiKeyboard
  /// to insert the text in the Textfield.
  void pressedEmoji(String emoji) {
    widget.emojiScrollShowBottomBar(true);
    widget.insertText(emoji, widget.categoryIndicator);
  }

  /// If the emojis are loaded the grid is already visible.
  /// We pass the emojis to the grid and we set the state to redraw the keyboard
  /// This will show the emojis correctly
  void forceUpdate(List<String> emojis, List<bool> available) {
    setState(() {
      this.available = available;
      this.emojis = emojis;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add global keys to the buttons to find the position
    List<GlobalKey> keys = [];
    for (int i = 0; i < emojis!.length; i++) {
      GlobalKey key = GlobalKey();
      keys.add(key);
    }

    bool isPortrait() {
      return MediaQuery.of(context).orientation == Orientation.portrait;
    }

    bool isTablet() {
      final display = PlatformDispatcher.instance.views.first.display;
      return display.size.shortestSide / display.devicePixelRatio < 600 ? false : true;
    }

    int getEmojiWidthCount() {
      if (isTablet()) {
        if (isPortrait()) {
          return 16;
        } else {
          return 32;
        }
      } else {
        if (isPortrait()) {
          return 8;
        } else {
          return 16;
        }
      }
    }

    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getEmojiWidthCount(),
        ),
        itemCount: emojis!.length,
        padding: const EdgeInsets.only(bottom: 60),
        itemBuilder: (BuildContext ctx, index) {
          return CustomPaint(
            foregroundPainter: hasComponent(emojis![index], index) ? BorderPainter() : null,
            child: Container(
              color: Colors.transparent,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: const Color(0xff898989),
                  onTap: () {
                    pressedEmoji(emojis![index]);
                  },
                  onLongPress: () {
                    if (hasComponent(emojis![index], index)) {
                      _showPopupMenu(keys[index], emojis![index]);
                    }
                  },
                  child: Container(
                    key: keys[index],
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(emojis![index], style: const TextStyle(fontSize: 500)),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  bool hasComponent(String emoji, int index) {
    if (widget.categoryIndicator != 1) {
      return false;
    } else {
      if (available.isNotEmpty) {
        return available[index];
      } else {
        return false;
      }
    }
  }

  void _showPopupMenu(GlobalKey keyKey, String emoji) async {
    List<String> components = [emoji];
    if (componentsMap.containsKey(emoji)) {
      components.addAll(componentsMap[emoji]!);
    }

    List<String> finalComponents = [];
    if (Platform.isAndroid) {
      List<dynamic>? availableEmojis =
          await platform.invokeMethod("isAvailable", {"emojis": components});
      if (availableEmojis != null) {
        for (var avail in availableEmojis) {
          finalComponents.add(avail.toString());
        }
      }
    } else {
      finalComponents = components;
    }

    RenderBox? box = keyKey.currentContext!.findRenderObject() as RenderBox?;

    Offset position = box!.localToGlobal(Offset.zero);

    double xPos = position.dx;
    double yPos = position.dy;
    double emojiWidth = widget.emojiSize;

    // We want the width to be 6 buttons wide,
    // the original emoji + 5 skin components
    // You can have more components, but it will always be at least 6.
    double widthPopup = widget.emojiSize * 6;
    double heightPopup = 0;
    if (finalComponents.length <= 6) {
      // Only 1 row needed. Show all emojis in a single row
      heightPopup = widget.emojiSize;
    } else if (finalComponents.length <= 12) {
      // Only 2 rows needed. Show all emojis in 2 rows
      heightPopup = widget.emojiSize * 2;
    } else {
      // More rows needed. Show all emojis by showing 2.5 rows,
      // showing that it can be scrolled
      heightPopup = widget.emojiSize * 2.5;
    }

    // The height of the position should reflect the height of the popup
    double heightPosition = 0;
    if (finalComponents.length <= 6) {
      heightPosition = yPos - (emojiWidth * 1);
    } else if (finalComponents.length <= 12) {
      heightPosition = yPos - (emojiWidth * 2);
    } else {
      heightPosition = yPos - (emojiWidth * 2.5);
    }

    RelativeRect popupPosition = RelativeRect.fromLTRB(xPos - (emojiWidth * 2) - (emojiWidth / 2),
        heightPosition, xPos + (emojiWidth * 3) + (emojiWidth / 2), yPos);

    if (navigator != null && capturedThemes != null) {
      showMenuOverride(
        position: popupPosition,
        widthPopup: widthPopup,
        heightPopup: heightPopup,
        navigator: navigator!,
        barrierLabel: barrierLabel,
        capturedThemes: capturedThemes!,
        items: [
          ComponentDetailPopup(
              key: UniqueKey(), components: finalComponents, addNewComponent: addNewComponent)
        ],
      ).then((value) {
        return;
      });
    }
  }

  void addNewComponent(String emojiComponent) {
    pressedEmoji(emojiComponent);
  }
}

// The arrow in the bottom right to indicate that there are,
// for instance, skin components on that emoji
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height;
    double sw = size.width;
    double cornerSide = sh * 0.05;
    double strokeWidth = 1.5;
    // strokewidth/2. This is so the indicator remains visible on the right side
    double tinyOffset = strokeWidth / 2;

    Paint paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    Path path = Path()
      ..moveTo(sw - cornerSide - tinyOffset, sh)
      ..lineTo(sw - tinyOffset, sh)
      ..lineTo(sw - tinyOffset, sh - cornerSide);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}
