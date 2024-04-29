import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:drive_memo/database/database_helper.dart';
import 'package:drive_memo/models/blog_item.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // Group all tests related to DatabaseHelper
  group('DatabaseHelper CRUD operations', () {
    late DatabaseHelper dbHelper;

    // Set up an instance of DatabaseHelper before each test
    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      await dbHelper.clearDatabase();  // Clear the database before each test
      await dbHelper.database;  // Re-initialize the database
    });

    // Close the database after each test
    tearDown(() async {
      await dbHelper.closeDatabase();  // Close the database after each test
    });

    test('Insert a BlogItem', () async {
      final blogItem = BlogItem(
          title: 'Test Title',
          date: DateTime.now(),
          bodyText: 'Test Content',
          imagePath: 'path/to/test/image.jpg'
      );
      await dbHelper.insertBlogItem(blogItem);

      final fetchedItems = await dbHelper.getBlogItems();
      expect(fetchedItems, isNotEmpty);
      expect(fetchedItems.first.title, equals(blogItem.title));
    });

    test('Update a BlogItem', () async {
      final blogItem = BlogItem(
          id: 1,
          title: 'Original Title',
          date: DateTime.now(),
          bodyText: 'Original Content',
          imagePath: 'path/to/original/image.jpg'
      );
      await dbHelper.insertBlogItem(blogItem);

      blogItem.title = 'Updated Title';
      blogItem.bodyText = 'Updated Content';
      await dbHelper.updateBlogItem(blogItem);

      final updatedItems = await dbHelper.getBlogItems();
      expect(updatedItems.first.title, equals('Updated Title'));
      expect(updatedItems.first.bodyText, equals('Updated Content'));
    });

    test('Delete a BlogItem', () async {
      // Insert a BlogItem to then delete
      final blogItem = BlogItem(
          title: 'To Delete',
          date: DateTime.now(),
          bodyText: 'Content to delete',
          imagePath: 'path/to/delete/image.jpg'
      );
      await dbHelper.insertBlogItem(blogItem);

      // Retrieve items to get the one with an ID
      final itemsBeforeDelete = await dbHelper.getBlogItems();
      expect(itemsBeforeDelete, isNotEmpty);

      // Perform deletion on the inserted item
      final itemToDelete = itemsBeforeDelete.first;
      await dbHelper.deleteBlogItem(itemToDelete.id!);

      // Verify the item has been deleted
      final itemsAfterDelete = await dbHelper.getBlogItems();
      expect(itemsAfterDelete, isEmpty);
    });

    test('Retrieve all BlogItems', () async {
      final blogItem1 = BlogItem(
          title: 'Item 1',
          date: DateTime.now(),
          bodyText: 'Content 1',
          imagePath: 'path/to/image1.jpg'
      );
      final blogItem2 = BlogItem(
          title: 'Item 2',
          date: DateTime.now().add(const Duration(days: 1)),
          bodyText: 'Content 2',
          imagePath: 'path/to/image2.jpg'
      );
      await dbHelper.insertBlogItem(blogItem1);
      await dbHelper.insertBlogItem(blogItem2);

      final allItems = await dbHelper.getBlogItems();
      expect(allItems.length, equals(2));
      expect(allItems.map((e) => e.title), containsAll(['Item 1', 'Item 2']));
    });
  });
}
