import 'package:emoji_keyboard_flutter/src/emoji/component/component.dart';
import 'package:emoji_keyboard_flutter/src/util/popup_menu_override.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// This is the Grid which will hold all the emojis
class EmojiGrid extends StatefulWidget {
  final List emojis;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String, int) insertText;
  final int categoryIndicator;
  final List<bool>? available;

  EmojiGrid({
    Key? key,
    required this.emojis,
    required this.emojiScrollShowBottomBar,
    required this.categoryIndicator,
    required this.insertText,
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
  List? emojis;
  ScrollController scrollController = new ScrollController();
  ScrollController scrollPopupController = new ScrollController();

  static const platform =
      const MethodChannel("nl.emojikeyboard.emoji/available");

  List<bool> available = [];
  @override
  void initState() {
    this.emojis = widget.emojis;
    if (widget.available != null) {
      this.available = widget.available!;
    }

    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  /// If the user scroll in the emoji we keep track of when the direction
  /// changes.
  /// If the user scrolls down a trigger is send to the bottom bar
  /// to hide the bottom bar if it was visible.
  /// If the user scrolls back up a trigger is send again to show the
  /// bottom bar if it was hidden
  keyboardScrollListener() {
    if (scrollController.hasClients) {
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
  void forceUpdate(emojis, available) {
    setState(() {
      this.available = available;
      this.emojis = emojis;
    });
  }

  bool isPortrait() {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  @override
  Widget build(BuildContext context) {
    // Add global keys to the buttons to find the position
    List<GlobalKey> keys = [];
    for (int i = 0; i < emojis!.length; i++) {
      GlobalKey key = GlobalKey();
      keys.add(key);
    }

    return GridView.builder(
        controller: scrollController,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isPortrait() ? 8 : 16,
        ),
        itemCount: emojis!.length,
        padding: EdgeInsets.only(bottom: 40),
        itemBuilder: (BuildContext ctx, index) {
          return CustomPaint(
            foregroundPainter:
                hasComponent(emojis![index], index) ? BorderPainter() : null,
            child: Container(
              key: keys[index],
              child: TextButton(
                  onPressed: () {
                    pressedEmoji(emojis![index]);
                  },
                  onLongPress: () {
                    if (hasComponent(emojis![index], index)) {
                      _showPopupMenu(keys[index], emojis![index]);
                    }
                  },
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(emojis![index], style: TextStyle(fontSize: 50)),
                  )),
            ),
          );
        });
  }

  hasComponent(String emoji, int index) {
    if (widget.categoryIndicator != 1) {
      return false;
    } else {
      if (available.length != 0) {
        return available[index];
      } else {
        return false;
      }
    }
  }

  _showPopupMenu(GlobalKey keyKey, String emoji) async {
    List<String> components = [emoji];
    components.addAll(componentsMap[emoji]);

    List<String> finalComponents = [];
    if (Platform.isAndroid) {
      var availableEmojis =
          await platform.invokeMethod("isAvailable", {"emojis": components});

      for (Object object in availableEmojis) {
        finalComponents.add(object.toString());
      }
    } else {
      finalComponents = components;
    }

    RenderBox? box = keyKey.currentContext!.findRenderObject() as RenderBox?;

    Offset position = box!.localToGlobal(Offset.zero);

    double xPos = position.dx;
    double yPos = position.dy;
    double emojiWidth = MediaQuery.of(context).size.width / 8;

    // We want the width to be 6 buttons wide,
    // the original emoji + 5 skin components
    // You can have more components, but it will always be at least 6.
    double widthPopup = (MediaQuery.of(context).size.width / 8) * 6;
    double heightPopup = 0;
    if (finalComponents.length <= 6) {
      // Only 1 row needed. Show all emojis in a single row
      heightPopup = (MediaQuery.of(context).size.width / 8);
    } else if (finalComponents.length <= 12) {
      // Only 2 rows needed. Show all emojis in 2 rows
      heightPopup = (MediaQuery.of(context).size.width / 8) * 2;
    } else {
      // More rows needed. Show all emojis by showing 2.5 rows,
      // showing that it can be scrolled
      heightPopup = (MediaQuery.of(context).size.width / 8) * 2.5;
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

    RelativeRect popupPosition = RelativeRect.fromLTRB(
        xPos - (emojiWidth * 2) - (emojiWidth / 2),
        heightPosition,
        xPos + (emojiWidth * 3) + (emojiWidth / 2),
        yPos);

    showMenuOverride(
      context: context,
      position: popupPosition,
      widthPopup: widthPopup,
      heightPopup: heightPopup,
      items: [
        ComponentDetailPopup(
            key: UniqueKey(),
            components: finalComponents,
            addNewComponent: addNewComponent)
      ],
    ).then((value) {
      return;
    });
  }

  addNewComponent(String emojiComponent) {
    pressedEmoji(emojiComponent);
  }
}

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
