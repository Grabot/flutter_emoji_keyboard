import 'package:flutter/material.dart';
import 'emoji_category_key.dart';

/// This is the Category bar. Here the user can select any of the 9 categories
class CategoryBar extends StatefulWidget {
  final Function(int) categoryHandler;
  final bool darkMode;

  const CategoryBar(
      {Key? key, required this.categoryHandler, required this.darkMode})
      : super(key: key);

  @override
  CategoryBarState createState() => CategoryBarState();
}

/// There are 8 emoji categories and a "recent" tab for the 9 categories total
/// Each category can be selected and it will jump to the corresponding category
/// The user can also switch to any category to the left or right of the current
/// category by swiping in that direction.
/// A difference in styling will indicate which category is selected.
/// The icons for the categories are also defined here.
class CategoryBarState extends State<CategoryBar> {
  int categorySelected = 1;
  double emojiCategoryHeight = 50;

  @override
  void initState() {
    super.initState();
  }

  /// If the user presses a emoji category key this function is called
  /// with the corresponding category number.
  /// The correct category is shown in the category bar and a trigger is
  /// send to the emoji page to show the page corresponding to the category.
  void onCategorySelect(int category) {
    widget.categoryHandler(category);
    if (categorySelected != category) {
      setState(() {
        categorySelected = category;
      });
    }
  }

  /// If the user swipes left or right in the emoji page the category changes.
  /// When that happens a trigger is send here to update the category bar
  /// to show the correct category corresponding to the page
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
      color: widget.darkMode ? Color(0xff171717) : Color(0xffdbdbdb),
      height: emojiCategoryHeight,
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
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
