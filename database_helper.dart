import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Folders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE Cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            name TEXT,
            image_url TEXT,
            FOREIGN KEY (folder_id) REFERENCES Folders (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Insert a new folder
  Future<int> insertFolder(String folderName) async {
    final db = await database;
    return await db.insert('Folders', {'folder_name': folderName});
  }

  // Update an existing folder
  Future<int> updateFolder(int id, String folderName) async {
    final db = await database;
    return await db.update(
      'Folders',
      {'folder_name': folderName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a folder
  Future<int> deleteFolder(int id) async {
    final db = await database;
    return await db.delete(
      'Folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch all folders
  Future<List<Map<String, dynamic>>> fetchFolders() async {
    final db = await database;
    return await db.query('Folders');
  }

  // Other database operations like fetchCards, insertCard, etc. can go here...
}
