import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiCategoryKey extends StatelessWidget {
  const EmojiCategoryKey(
      {
        Key? key,
        required this.onCategorySelect,
        required this.category,
        required this.categoryNumber,
        required this.active
      })
      : super(key: key);

  final ValueSetter<int> onCategorySelect;
  final IconData category;
  final int categoryNumber;
  final bool active;

  Widget build(BuildContext context) {
    return Container(
      decoration: active
          ? BoxDecoration(
              shape: BoxShape.circle, color: Colors.blueGrey.shade200)
          : BoxDecoration(),
      child: SizedBox(
          width:
              MediaQuery.of(context).size.width / 9, // make it 9 buttons wide
          height: MediaQuery.of(context).size.width / 9, // make it square
          child: IconButton(
            icon: Icon(category),
            color: active ? Colors.black : Colors.grey.shade600,
            onPressed: () {
              onCategorySelect.call(categoryNumber);
            },
          )),
    );
  }
}
