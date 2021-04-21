import 'package:flutter/material.dart';
import 'emoji_category_key.dart';

class CategoryBar extends StatefulWidget {

  const CategoryBar({
    Key key,
    this.categoryHandler
  }) : super(key: key);

  final Function(int) categoryHandler;

  @override
  CategoryBarState createState() => CategoryBarState();
}

class CategoryBarState extends State<CategoryBar> {

  int categorySelected;
  double emojiCategoryHeight;

  @override
  void initState() {
    emojiCategoryHeight = 50;
    categorySelected = 1;

    super.initState();
  }

  void onCategorySelect(int category) {
    widget.categoryHandler(category);
    if (categorySelected != category) {
      setState(() {
        categorySelected = category;
      });
    }
  }

  void updateCategoryBar(int categoryNumber) {
    if (categoryNumber != categorySelected) {
      setState(() {
        categorySelected = categoryNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: emojiCategoryHeight,
      width: MediaQuery.of(context).size.width,
      child:SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.access_time,
              categoryNumber: 0,
              active: categorySelected == 0,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.tag_faces,
              categoryNumber: 1,
              active: categorySelected == 1,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.pets,
              categoryNumber: 2,
              active: categorySelected == 2,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.fastfood,
              categoryNumber: 3,
              active: categorySelected == 3,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.sports_soccer,
              categoryNumber: 4,
              active: categorySelected == 4,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.directions_car,
              categoryNumber: 5,
              active: categorySelected == 5,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.lightbulb_outline,
              categoryNumber: 6,
              active: categorySelected == 6,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.euro_symbol,
              categoryNumber: 7,
              active: categorySelected == 7,
            ),
            EmojiCategoryKey(
              onCategorySelect: onCategorySelect,
              category: Icons.flag,
              categoryNumber: 8,
              active: categorySelected == 8,
            ),
          ],
        ),
      ),
    );
  }
}

