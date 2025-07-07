import 'package:emoji_keyboard_flutter/src/util/emoji.dart';
import 'package:emoji_keyboard_flutter/src/util/storage.dart';
import 'package:flutter/material.dart';

/// The actions that can be performed in the emoji popup.
abstract class EmojiPopupAction {
  const EmojiPopupAction();
}

/// The emoji selected action. This will be triggered when an emoji is selected.
class EmojiSelected extends EmojiPopupAction {
  final String emoji;
  const EmojiSelected(this.emoji);
}

/// The button pressed action. This will be triggered when the "+" button is pressed.
class ButtonPressed extends EmojiPopupAction {
  const ButtonPressed();
}

/// The outside clicked action. This will be triggered when the user clicks outside the widget.
class OutsideClicked extends EmojiPopupAction {
  const OutsideClicked();
}

/// The emoji popup Widget. This is a quick emoji access
/// that will be shown on the position passed in the constructor.
class EmojiKeyboardPopup extends StatefulWidget {
  final Offset position;
  final void Function(EmojiPopupAction) onAction;
  final bool showEmojiPopup;
  final bool darkMode;
  final double? popupWidth;
  final String? highlightedEmoji;
  final Duration? emojiPopupAnimationDuration;

  const EmojiKeyboardPopup(
      {required this.position,
      required this.onAction,
      required this.showEmojiPopup,
      Key? key,
      this.darkMode = false,
      this.popupWidth,
      this.highlightedEmoji,
      this.emojiPopupAnimationDuration})
      : super(key: key);

  @override
  EmojiBoardPopup createState() => EmojiBoardPopup();
}

/// The emoji popup is a small widget with a horizontal listview containing emojis.
/// You can scroll through the emojis and select one.
/// This will trigger the EmojiSelected callback.
/// You can also press the "+" button which will also trigger a ButtonPressed callback
/// If you press outside the widget it will trigger the OutsideClicked callback.
/// It also has a darkmode for the users with a good taste in styling.
class EmojiBoardPopup extends State<EmojiKeyboardPopup> {
  bool darkMode = false;
  List<Emoji> recent = [];
  List<String> recentEmojis = [];
  final ScrollController _scrollController = ScrollController();
  Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    darkMode = widget.darkMode;

    // Hardcoded selection of emojis that are useful for quick emoji reactions.
    recent.add(Emoji('👍', 1));
    recent.add(Emoji('👎', 1));
    recent.add(Emoji('❤️', 1));
    recent.add(Emoji('😂', 1));
    recent.add(Emoji('🔥', 1));
    recent.add(Emoji('🎉', 1));
    recent.add(Emoji('🤔', 1));
    recent.add(Emoji('🙏', 1));
    recent.add(Emoji('🤣', 1));
    recent.add(Emoji('😱', 1));
    recent.add(Emoji('👏', 1));
    recent.add(Emoji('💯', 1));
    recent.add(Emoji('😘', 1));
    recent.add(Emoji('😎', 1));
    recent.add(Emoji('🤷', 1));
    recentEmojis = recent.map((emote) => emote.emoji).toList();

    storage.fetchAllEmojis().then((emojis) {
      if (emojis.isNotEmpty) {
        emojis.sort((a, b) => b.amount.compareTo(a.amount));
        recent.addAll(emojis);
        recent.add(Emoji('', 1));
        recentEmojis = recent.map((emote) => emote.emoji).toList();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double widgetWidth = 350;
    if (widget.popupWidth != null) {
      widgetWidth = widget.popupWidth!;
    }
    double left = widget.position.dx - (widgetWidth / 2);
    double top = widget.position.dy - (60 / 2) - 100;
    if (left < 0) {
      left = 0;
    } else if (left + widgetWidth > screenWidth) {
      left = screenWidth - widgetWidth;
    }
    if (top < 0) {
      top = 0;
    } else if (top + 60 > screenHeight) {
      top = screenHeight - 60;
    }

    return Stack(
      children: [
        if (widget.showEmojiPopup)
          GestureDetector(
            onTap: () => widget.onAction(const OutsideClicked()),
            child: Container(
              color: Colors.transparent,
              width: screenWidth,
              height: screenHeight,
            ),
          ),
        Positioned(
          left: left,
          top: top,
          child: AnimatedContainer(
            duration: widget.emojiPopupAnimationDuration ?? Duration.zero,
            curve: Curves.easeInOut,
            width: widget.showEmojiPopup ? widgetWidth : 0,
            height: widget.showEmojiPopup ? 50 : 0,
            decoration: BoxDecoration(
              color: darkMode ? const Color(0xff373737) : Colors.grey,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: widget.showEmojiPopup
                ? Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: recentEmojis.length,
                        itemBuilder: (context, index) {
                          final isHighlighted =
                              recentEmojis[index] == widget.highlightedEmoji;
                          return AnimatedBuilder(
                            animation: _scrollController,
                            builder: (context, child) {
                              // Fade in and out for emojis in the horizontal listview
                              final itemPosition = index * 50.0;
                              final scrollPosition =
                                  _scrollController.offset - 40;
                              const fadeOutWidth = 40.0;
                              final distanceFromCenter = (itemPosition -
                                      scrollPosition -
                                      (widgetWidth / 2))
                                  .abs();
                              final opacity = 1.0 -
                                  ((distanceFromCenter -
                                              (widgetWidth / 2 - fadeOutWidth))
                                          .clamp(0.0, fadeOutWidth) /
                                      fadeOutWidth);
                              return Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: child,
                              );
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  widget.onAction(
                                      EmojiSelected(recentEmojis[index]));
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: isHighlighted
                                      ? BoxDecoration(
                                          color: widget.darkMode
                                              ? Colors.white
                                                  .withValues(alpha: 0.2)
                                              : Colors.black
                                                  .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        )
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(recentEmojis[index],
                                          style:
                                              const TextStyle(fontSize: 500)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: -4,
                        top: 0,
                        bottom: 0,
                        child: Align(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: IconButton(
                              icon: const Icon(Icons.add),
                              color: Colors.white,
                              iconSize: 16,
                              padding: const EdgeInsets.all(4),
                              onPressed: () {
                                widget.onAction(const ButtonPressed());
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xff808080),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
