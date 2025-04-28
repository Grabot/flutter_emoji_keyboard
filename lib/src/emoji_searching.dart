import 'emoji/activities.dart';
import 'emoji/animals.dart';
import 'emoji/flags.dart';
import 'emoji/foods.dart';
import 'emoji/objects.dart';
import 'emoji/smileys.dart';
import 'emoji/symbols.dart';
import 'emoji/travel.dart';

/// When this is called it receives a text and it return all the emojis which
/// are related to that text and which the user might be looking for.
/// It looks for exact or partial matches with the emoji name and the given text
List<String> searchEmojis(String text) {
  if (text.isNotEmpty) {
    List<SearchedEmoji> recommendedEmojis = [];

    List<List<List<dynamic>>> allEmojis = [
      smileysList,
      animalsList,
      foodsList,
      activitiesList,
      travelList,
      objectsList,
      symbolsList,
      flagsList
    ];
    for (var emojiList in allEmojis) {
      for (var emoji in emojiList) {
        String emojiString = emoji[0] as String;
        String description = emoji[1] as String;
        List<String> descriptionSplit =
            description.replaceAll(":", "").replaceAll("-", " ").split(" ");
        List<String> splitName = emoji[2] as List<String>;
        splitName.addAll(descriptionSplit);

        splitName = splitName.toSet().toList();

        if (text.contains(" ")) {
          getRecommendedEmojis(recommendedEmojis, splitName, text, emojiString);
          text.split(" ").forEach((textSplit) {
            if (textSplit != "") {
              getRecommendedEmojis(
                  recommendedEmojis, splitName, textSplit, emojiString);
            }
          });
        } else {
          getRecommendedEmojis(recommendedEmojis, splitName, text, emojiString);
        }
      }
    }

    recommendedEmojis.sort((a, b) {
      if (a.tier < b.tier) {
        return -1;
      } else if (a.tier > b.tier) {
        return 1;
      } else {
        if (a.tier == 1 && b.tier == 1) {
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
              if (a.searchHits < b.searchHits) {
                return -1;
              } else if (a.searchHits > b.searchHits) {
                return 1;
              } else {
                return 0;
              }
            }
          }
        } else {
          if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
            return -1;
          } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
            return 1;
          } else {
            if (a.searchHits < b.searchHits) {
              return -1;
            } else if (a.searchHits > b.searchHits) {
              return 1;
            } else {
              return 0;
            }
          }
        }
      }
    });

    return recommendedEmojis.map((emote) => emote.emoji).toList();
  } else {
    return [];
  }
}

void getRecommendedEmojis(List<SearchedEmoji> recommendedEmojis,
    List<String> splitName, String text, String emojiString) {
  int numSplitEqualKeyword = 0;
  int numSplitPartialKeyword = 0;
  for (var splitName in splitName) {
    if (splitName == text.toLowerCase()) {
      numSplitEqualKeyword += 1;
    } else if (splitName.toLowerCase().contains(text.toLowerCase())) {
      numSplitPartialKeyword += 1;
    }

    if (numSplitEqualKeyword > 0) {
      List<String> searchedEmojiList =
          recommendedEmojis.map((emote) => emote.emoji).toList();
      if (searchedEmojiList.contains(emojiString)) {
        SearchedEmoji currentSearchedEmoji =
            recommendedEmojis.firstWhere((emote) => emote.emoji == emojiString);
        currentSearchedEmoji.setTier(1);

        currentSearchedEmoji.addSearchHit();
        currentSearchedEmoji.addNumSplitEqualKeyword(numSplitEqualKeyword);
        currentSearchedEmoji.addNumSplitPartialKeyword(numSplitPartialKeyword);
      } else {
        recommendedEmojis.add(SearchedEmoji(
            emoji: emojiString,
            tier: 1,
            numSplitEqualKeyword: numSplitEqualKeyword,
            numSplitPartialKeyword: numSplitPartialKeyword,
            searchHits: 1));
      }
    } else if (numSplitPartialKeyword > 0) {
      List<String> searchedEmojiList =
          recommendedEmojis.map((emote) => emote.emoji).toList();
      if (searchedEmojiList.contains(emojiString)) {
        SearchedEmoji currentSearchedEmoji =
            recommendedEmojis.firstWhere((emote) => emote.emoji == emojiString);
        currentSearchedEmoji.addSearchHit();
        currentSearchedEmoji.addNumSplitEqualKeyword(numSplitEqualKeyword);
        currentSearchedEmoji.addNumSplitPartialKeyword(numSplitPartialKeyword);
      } else {
        recommendedEmojis.add(SearchedEmoji(
            emoji: emojiString,
            tier: 2,
            numSplitPartialKeyword: numSplitPartialKeyword,
            searchHits: 1));
      }
    }
  }
}

/// Here we store the emoji that the user searched for. We store the tier and
/// the name and the emoji.
/// We use the tier to sort them in the order in which the user probably wants.
/// The searched word is matched with how well it matches the emoji name.
/// If the word matches exact it will be a stronger factor than partially
class SearchedEmoji {
  final String emoji;
  int tier;
  int numSplitEqualKeyword;
  int numSplitPartialKeyword;
  int searchHits;

  SearchedEmoji(
      {required this.emoji,
      required this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0,
      this.searchHits = 0});

  void setTier(int tier) {
    this.tier = tier;
  }

  void addSearchHit() {
    searchHits += 1;
  }

  void addNumSplitEqualKeyword(int addedNumSplit) {
    numSplitEqualKeyword += addedNumSplit;
  }

  void addNumSplitPartialKeyword(int addedNumSplit) {
    numSplitPartialKeyword += addedNumSplit;
  }
}
