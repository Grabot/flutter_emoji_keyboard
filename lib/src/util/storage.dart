import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'emoji.dart';


class Storage {
  static const _dbName = "flutter_emoji_keyboard.db";

  static final Storage _instance = Storage._internal();

  var based;

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  Future<Database> get database async {
    if (based != null) return based;
    based = await _initDatabase();
    return based;
  }

  // Creates and opens the database.
  _initDatabase() async {
    print("initializing the database");
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Creates the database structure (unless database has already been created)
  Future _onCreate(
      Database db,
      int version,
      ) async {
    await createTableEmoji(db);
  }

  createTableEmoji(Database db) async {
    print("create table Emojis");
    await db.execute('''
    CREATE TABLE Emojis (
            id INTEGER PRIMARY KEY,
            emojiDescription TEXT,
            emoji TEXT,
            amount INTEGER,
            UNIQUE(emojiDescription) ON CONFLICT REPLACE
          );
          ''');
  }

  Future<int> addEmoji(Emoji emoji) async {
    Database database = await this.database;
    return database.insert(
      'Emojis',
      emoji.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Emoji>> fetchAllEmojis() async {
    Database database = await this.database;
    String query = "SELECT * FROM Emojis";
    List<Map<String, dynamic>> emojis = await database.rawQuery(query);
    print("all emojis");
    print(emojis);
    if (emojis.isNotEmpty) {
      return emojis.map((map) => Emoji.fromDbMap(map)
      ).toList();
    }
    return List.empty();
  }

  Future<int> updateEmoji(Emoji emoji) async {
    Database database = await this.database;
    return database.update(
      'Emojis',
      emoji.toDbMap(),
      where: 'emojiDescription = ?',
      whereArgs: [emoji.emojiDescription],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}