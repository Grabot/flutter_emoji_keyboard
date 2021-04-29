import 'emojis/activities.dart';
import 'emojis/animals.dart';
import 'emojis/flags.dart';
import 'emojis/foods.dart';
import 'emojis/objects.dart';
import 'emojis/smileys.dart';
import 'emojis/symbols.dart';
import 'emojis/travel.dart';

List<String> searchEmojis(String text) {
  if (text.length >= 1) {
    List<SearchedEmoji> recommendedEmojis = [];

    List allEmojis = [
      smileysList,
      animalsList,
      foodsList,
      activitiesList,
      travelList,
      objectsList,
      symbolsList,
      flagsList
    ];
    allEmojis.forEach((emojiList) {
      emojiList.forEach((emoji) {
        int numSplitEqualKeyword = 0;
        int numSplitPartialKeyword = 0;

        String description = emoji[0];

        List<String> splitName = description.split(" ");
        splitName.forEach((splitName) {
          if (splitName.replaceAll(":", "").toLowerCase() ==
              text.toLowerCase()) {
            numSplitEqualKeyword += 1;
          } else if (splitName
              .replaceAll(":", "")
              .toLowerCase()
              .contains(text.toLowerCase())) {
            numSplitPartialKeyword += 1;
          }

          if (numSplitEqualKeyword > 0) {
            if (numSplitEqualKeyword == description.split(" ").length) {
              recommendedEmojis.add(
                  SearchedEmoji(name: description, emoji: emoji[1], tier: 1));
            } else {
              recommendedEmojis.add(SearchedEmoji(
                  name: description,
                  emoji: emoji[1],
                  tier: 2,
                  numSplitEqualKeyword: numSplitEqualKeyword,
                  numSplitPartialKeyword: numSplitPartialKeyword));
            }
          } else if (numSplitPartialKeyword > 0) {
            recommendedEmojis.add(SearchedEmoji(
                name: description,
                emoji: emoji[1],
                tier: 3,
                numSplitPartialKeyword: numSplitPartialKeyword));
          }
        });
      });
    });

    recommendedEmojis.sort((a, b) {
      if (a.tier < b.tier) {
        return -1;
      } else if (a.tier > b.tier) {
        return 1;
      } else {
        if (a.tier == 1) {
          if (a.name.split(" ").length > b.name.split(" ").length) {
            return -1;
          } else if (a.name.split(" ").length < b.name.split(" ").length) {
            return 1;
          } else {
            return 0;
          }
        } else if (a.tier == 2) {
          if (a.numSplitEqualKeyword > b.numSplitEqualKeyword) {
            return -1;
          } else if (a.numSplitEqualKeyword < b.numSplitEqualKeyword) {
            return 1;
          } else {
            if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
              return -1;
            } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
              return 1;
            } else {
              if (a.name.split(" ").length < b.name.split(" ").length) {
                return -1;
              } else if (a.name.split(" ").length > b.name.split(" ").length) {
                return 1;
              } else {
                return 0;
              }
            }
          }
        } else if (a.tier == 3) {
          if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
            return -1;
          } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
            return 1;
          } else {
            return 0;
          }
        }
      }

      return 0;
    });

    Set<String> finalEmojis = {};
    recommendedEmojis.forEach((element) {
      finalEmojis.add(element.emoji.toString());
    });
    return finalEmojis.toList();
  } else {
    return [];
  }
}

class SearchedEmoji {
  final String name;
  final String emoji;
  final int tier;
  final int numSplitEqualKeyword;
  final int numSplitPartialKeyword;

  SearchedEmoji(
      {this.name,
      this.emoji,
      this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0});

  @override
  String toString() {
    return "emoji $emoji  and full description $name";
  }
}
