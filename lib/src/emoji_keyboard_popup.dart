import 'package:flutter/material.dart';
import 'dart:math';

class EmojiKeyboardPopup extends StatefulWidget {
  final bool darkMode;
  final Offset position;
  final VoidCallback onClose;

  const EmojiKeyboardPopup({
    Key? key,
    this.darkMode = false,
    required this.position,
    required this.onClose,
  }) : super(key: key);

  @override
  EmojiBoardPopup createState() => EmojiBoardPopup();
}

class EmojiBoardPopup extends State<EmojiKeyboardPopup> {
  bool darkMode = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    darkMode = widget.darkMode;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Color _getBackgroundColor() {
    return darkMode ? const Color(0xff373737) : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final widgetWidth = screenWidth * 0.75;

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
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.transparent,
            width: screenWidth,
            height: screenHeight,
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: widgetWidth,
              height: 50,
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          final itemPosition = index * 50.0;
                          final scrollPosition = _scrollController.offset - 50;
                          final fadeOutWidth = 40.0;

                          final distanceFromCenter = (itemPosition - scrollPosition - (widgetWidth / 2)).abs();

                          final opacity = 1.0 - ((distanceFromCenter - (widgetWidth / 2 - fadeOutWidth)).clamp(0.0, fadeOutWidth) / fadeOutWidth);
                          if (index == 6) {
                            print("_scrollController ${_scrollController.offset}  opacity: $opacity");
                          }
                          return Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getRandomColor(),
                            borderRadius: BorderRadius.circular(50.0),
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
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                        onPressed: () {
                          // Handle the button tap
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xff808080),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}