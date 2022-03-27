import 'package:emoji_keyboard_flutter/src/util/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This is the Grid which will hold all the emojis
class EmojiGrid extends StatefulWidget {
  final List emojis;
  final Function(bool) emojiScrollShowBottomBar;
  final Function(String, int) insertText;
  final int categoryIndicator;

  EmojiGrid({
    Key? key,
    required this.emojis,
    required this.emojiScrollShowBottomBar,
    required this.categoryIndicator,
    required this.insertText
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

  @override
  void initState() {
    this.emojis = widget.emojis;

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

  void getExtraEmojiOptions(Emoji emoji) {
    print(emoji.emoji);
  }

  /// If the emojis are loaded the grid is already visible.
  /// We pass the emojis to the grid and we set the state to redraw the keyboard
  /// This will show the emojis correctly
  void forceUpdate(emojis) {
    setState(() {
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
            foregroundPainter: emojis![index].testComponent ? BorderPainter() : NoBorderPainter(),
            child: Container(
              key: keys[index],
              child: TextButton(
                  onPressed: () {
                    pressedEmoji(emojis![index].emoji);
                  },
                  onLongPress: () {
                    _showPopupMenu(keys[index]);
                  },
                  child: Text(emojis![index].emoji, style: TextStyle(fontSize: 25))),
            ),
          );
        });
  }

  _showPopupMenu(GlobalKey keyKey) async {
    RenderBox? box = keyKey.currentContext!.findRenderObject() as RenderBox?;

    Offset position = box!.localToGlobal(Offset.zero);

    double xPos = position.dx;
    double yPos = position.dy;
    double emojiWidth = MediaQuery.of(context).size.width / 8;
    RelativeRect test = RelativeRect.fromLTRB(
      xPos,
      yPos,
      xPos + emojiWidth,
      yPos + emojiWidth
    );

    showMenu(
        context: context,
        items: [
          ComponentDetailPopup(
              key: UniqueKey()
          )
        ],
        position: test)
        .then((int? delta) {
      return;
    });
  }

}

class NoBorderPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height;
    double sw = size.width;
    double cornerSide = sh * 0.05;
    double strokeWidth = 1.5;
    // strokewidth/2. This is so the indicator remains visible on the right side
    double tinyOffset = strokeWidth/2;

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

class ComponentDetailPopup extends PopupMenuEntry<int> {
  ComponentDetailPopup(
      {required Key key})
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  ComponentDetailPopupState createState() => ComponentDetailPopupState();

  @override
  double get height => 1;
}

class ComponentDetailPopupState extends State<ComponentDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

Widget getPopupItems(BuildContext context) {
  return Row(children: [
    Container(
      height: MediaQuery.of(context).size.width / 8,
      width: ((MediaQuery.of(context).size.width / 8) * 5),
      alignment: Alignment.center,
      color: Colors.red,
      child: CustomPaint(
        foregroundPainter: NoBorderPainter(),
        child: Container(
          child: TextButton(
              onPressed: () {
                print("press component");
              },
              child: Text('👋🏻', style: TextStyle(fontSize: 25))),
        ),
      )
    )
  ]);
}
