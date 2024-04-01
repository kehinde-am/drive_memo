import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/blog_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  // This method ensures that the database is initialized only once and reused.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database at the correct path.
  Future<Database> _initDatabase() async {
    // Use getDatabasesPath() to find the default database directory and join it with your database name.
    final path = join(await getDatabasesPath(), 'drive_memo.db');
    // Print the path to the console for debugging purposes.

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }


  // Create the database schema.
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

  // Insert a blog item into the database.
  Future<void> insertBlogItem(BlogItem blogItem) async {
    final Database db = await database;
    try {
      await db.insert(
        'blog_items',
        blogItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("Error inserting blog item: $e");
      rethrow;
    }
  }

  // Retrieve all blog items from the database.
  Future<List<BlogItem>> getBlogItems() async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query('blog_items');
      return result.map((map) => BlogItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Error fetching blog items: $e");
      rethrow;
    }
  }

  // Update a blog item in the database.
  Future<void> updateBlogItem(BlogItem blogItem) async {
    final db = await database;
    await db.update(
      'blog_items',
      blogItem.toMap(),
      where: 'id = ?',
      whereArgs: [blogItem.id],
    );
  }

  // Delete a blog item from the database.
  Future<void> deleteBlogItem(int id) async {
    final db = await database;
    await db.delete(
      'blog_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



}
