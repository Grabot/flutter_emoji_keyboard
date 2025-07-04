class Emoji {
  late String emoji;
  late int amount;

  Emoji(this.emoji, this.amount);

  void increase() {
    amount += 1;
  }

  Map<String, dynamic> toDbMap() {
    final map = <String, dynamic>{};
    map['emoji'] = emoji;
    map['amount'] = amount;
    return map;
  }

  Emoji.fromDbMap(Map<String, dynamic> map) {
    emoji = map['emoji'] as String;
    amount = map['amount'] as int;
  }
}
