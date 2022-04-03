class Emoji {
  late String emojiDescription;
  late String emoji;
  late int amount;
  bool hasComponent = false;

  Emoji(String emojiDescription, String emoji, int amount) {
    this.emojiDescription = emojiDescription;
    this.emoji = emoji;
    this.amount = amount;
  }

  increase() {
    this.amount += 1;
  }

  hasCompo() {
    hasComponent = true;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['emojiDescription'] = emojiDescription;
    map['emoji'] = emoji;
    map['amount'] = amount;
    return map;
  }

  Emoji.fromDbMap(Map<String, dynamic> map) {
    emojiDescription = map['emojiDescription'];
    emoji = map['emoji'];
    amount = map['amount'];
  }
}
