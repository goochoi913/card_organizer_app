import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return await db.insert('cards', card.toMap());
  }

  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'order_index ASC', // FIXED LEXICOGRAPHIC SORTING
    );
    return List.generate(maps.length, (i) => PlayingCard.fromMap(maps[i]));
  }

  Future<int> updateCard(PlayingCard card) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<int, int>> getCardCountsByFolder() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT folder_id, COUNT(*) AS count
      FROM cards
      GROUP BY folder_id
    ''');

    final counts = <int, int>{};
    for (final row in rows) {
      final folderId = row['folder_id'];
      final count = row['count'];
      if (folderId is int && count is int) {
        counts[folderId] = count;
      }
    }
    return counts;
  }

  // NEW METHOD FOR DRAG AND DROP BONUS
  Future<void> updateCardOrders(List<PlayingCard> cards) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (int i = 0; i < cards.length; i++) {
      batch.update(
        'cards',
        {'order_index': i},
        where: 'id = ?',
        whereArgs: [cards[i].id],
      );
    }
    await batch.commit();
  }
}
