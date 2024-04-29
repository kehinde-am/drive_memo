import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blog_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'drive_memo.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blog_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        body_text TEXT,
        image_path TEXT
      )
    ''');
  }

  Future<void> insertBlogItem(BlogItem blogItem) async {
    final Database db = await database;
    await db.transaction((txn) async {
      try {
        await txn.insert(
          'blog_items',
          blogItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        debugPrint("Error inserting blog item: $e");
        rethrow;
      }
    });
  }

  Future<List<BlogItem>> getBlogItems() async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query('blog_items');
    return result.map((map) => BlogItem.fromMap(map)).toList();
  }

  Future<void> updateBlogItem(BlogItem blogItem) async {
    final db = await database;
    await db.update(
      'blog_items',
      blogItem.toMap(),
      where: 'id = ?',
      whereArgs: [blogItem.id],
    );
  }

  Future<void> deleteBlogItem(int id) async {
    final db = await database;
    await db.delete('blog_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final path = join(await getDatabasesPath(), 'drive_memo.db');
    await deleteDatabase(path);
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
  }
}
