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

  @override
  void initState() {
    darkMode = widget.darkMode;
    super.initState();
  }

  @override
  void dispose() {
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
              height: 60,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 40,
                        height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: _getRandomColor(),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                },
              ),
                  Positioned(
                    right: 8.0,
                    top: 8.0,
                    child: GestureDetector(
                      onTap: () {
                        // Handle the button tap
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
