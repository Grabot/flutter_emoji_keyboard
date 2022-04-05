import 'test/activities.dart';
import 'test/animals.dart';
import 'test/flags.dart';
import 'test/foods.dart';
import 'test/objects.dart';
import 'test/smileys.dart';
import 'test/symbols.dart';
import 'test/travel.dart';

/// When this is called it receives a text and it return all the emojis which
/// are related to that text and which the user might be looking for.
/// It looks for exact or partial matches with the emoji name and the given text
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

        String emojiString = emoji[0];
        String description = emoji[1];
        List<String> splitName = emoji[2];

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
            if (numSplitEqualKeyword == splitName.length) {
              recommendedEmojis.add(
                  SearchedEmoji(name: description, emoji: emoji[0], tier: 1));
            } else {
              recommendedEmojis.add(SearchedEmoji(
                  name: description,
                  emoji: emojiString,
                  tier: 2,
                  numSplitEqualKeyword: numSplitEqualKeyword,
                  numSplitPartialKeyword: numSplitPartialKeyword));
            }
          } else if (numSplitPartialKeyword > 0) {
            recommendedEmojis.add(SearchedEmoji(
                name: description,
                emoji: emojiString,
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
      finalEmojis.add(element.emoji);
    });
    return finalEmojis.toList();
  } else {
    return [];
  }
}

/// Here we store the emoji that the user searched for. We store the tier and
/// the name and the emoji.
/// We use the tier to sort them in the order in which the user probably wants.
/// The searched word is matched with how well it matches the emoji name.
/// If the word matches exact it will be a stronger factor than partially
class SearchedEmoji {
  final String name;
  final String emoji;
  final int tier;
  final int numSplitEqualKeyword;
  final int numSplitPartialKeyword;

  SearchedEmoji(
      {required this.name,
      required this.emoji,
      required this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0});
}
