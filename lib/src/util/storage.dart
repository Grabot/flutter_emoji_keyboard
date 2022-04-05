import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'emoji.dart';

/// The storage. This holds all the components of the local db.
/// Here we will be able to:
/// - initialize the database
/// - create a new Emoji table, if none exist yet.
/// - get all entries in the emoji table.
/// - add a emoji emoji entry in the db.
/// - update an existing emoji entry to increase the count.
class Storage {
  static const _dbName = "emoji_keyboard.db";

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

  /// Creates and opens the database.
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Creates the database structure (unless database has already been created)
  Future _onCreate(
    Database db,
    int version,
  ) async {
    await createTableEmoji(db);
  }

  createTableEmoji(Database db) async {
    await db.execute('''
    CREATE TABLE Emojis (
            id INTEGER PRIMARY KEY,
            emoji TEXT,
            amount INTEGER,
            UNIQUE(emoji) ON CONFLICT REPLACE
          );
          ''');
  }

  Future<List<Emoji>> fetchAllEmojis() async {
    Database database = await this.database;
    String query = "SELECT * FROM Emojis";
    List<Map<String, dynamic>> emojis = await database.rawQuery(query);
    if (emojis.isNotEmpty) {
      return emojis.map((map) => Emoji.fromDbMap(map)).toList();
    }
    return List.empty();
  }

  Future<int> addEmoji(Emoji emoji) async {
    Database database = await this.database;
    return database.insert(
      'Emojis',
      emoji.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateEmoji(Emoji emoji) async {
    Database database = await this.database;
    return database.update(
      'Emojis',
      emoji.toDbMap(),
      where: 'emoji = ?',
      whereArgs: [emoji.emoji],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
