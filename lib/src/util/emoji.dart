class Emoji {
  late String emoji;
  late int amount;

  Emoji(String emoji, int amount) {
    this.emoji = emoji;
    this.amount = amount;
  }

  increase() {
    this.amount += 1;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['emoji'] = emoji;
    map['amount'] = amount;
    return map;
  }

  Emoji.fromDbMap(Map<String, dynamic> map) {
    emoji = map['emoji'];
    amount = map['amount'];
  }
}
