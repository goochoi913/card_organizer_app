import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // BUMPED TO VERSION 2 to force a clean upgrade
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON'); // CASCADE FIX
      },
      onOpen: (db) async {
        await _createIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Automatically wipes and rebuilds the DB for you
        await db.execute('DROP TABLE IF EXISTS cards');
        await db.execute('DROP TABLE IF EXISTS folders');
        await db.execute('DROP TABLE IF EXISTS themes');
        await _createDB(db, newVersion);
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        order_index INTEGER DEFAULT 0, -- FOR DRAG AND DROP
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE themes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_name TEXT NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
    await _createIndexes(db);
    await db.insert('themes', {
      'theme_name': 'Default Light',
      'is_active': 1,
    }); // BONUS: THEMES
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cards_folder_id ON cards(folder_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cards_folder_order ON cards(folder_id, order_index)',
    );
  }

  Future _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    for (int i = 0; i < folders.length; i++) {
      await db.insert('folders', {
        'folder_name': folders[i],
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cards = [
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King',
    ];

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      int orderIdx = 1;
      for (var card in cards) {
        await db.insert('cards', {
          'card_name': card,
          'suit': suits[folderId - 1],
          'image_url':
              'assets/cards/${suits[folderId - 1].toLowerCase()}_${card.toLowerCase()}.png',
          'folder_id': folderId,
          'order_index': orderIdx++, // FIXES SORTING
        });
      }
    }
  }
}
