import 'package:flutter_test/flutter_test.dart';
import 'package:drive_memo/models/blog_item.dart';

void main() {
  group('BlogItem', () {
    test('should convert a BlogItem object to a map', () {
      final date = DateTime.now();
      final blogItem = BlogItem(
        id: 1,
        title: 'Test Post',
        date: date,
        bodyText: 'This is a test post.',
        imagePath: 'path/to/image.jpg',
      );

      final result = blogItem.toMap();
      expect(result, {
        'id': 1,
        'title': 'Test Post',
        'date': date.toIso8601String(),
        'body_text': 'This is a test post.',
        'image_path': 'path/to/image.jpg',
      });
    });

    test('should construct a BlogItem from a map', () {
      final map = {
        'id': 1,
        'title': 'Test Post',
        'date': '2021-04-01T14:00:00Z',
        'body_text': 'This is a test post.',
        'image_path': 'path/to/image.jpg',
      };
      final blogItem = BlogItem.fromMap(map);

      expect(blogItem.id, 1);
      expect(blogItem.title, 'Test Post');
      expect(blogItem.date, DateTime.parse('2021-04-01T14:00:00Z'));
      expect(blogItem.bodyText, 'This is a test post.');
      expect(blogItem.imagePath, 'path/to/image.jpg');
    });

    test('should return a correctly formatted string from toString', () {
      final date = DateTime.now();
      final blogItem = BlogItem(
        id: 1,
        title: 'Test Post',
        date: date,
        bodyText: 'This is a test post.',
        imagePath: 'path/to/image.jpg',
      );

      final string = blogItem.toString();
      expect(string, 'BlogItem{id: 1, title: Test Post, date: ${date.toIso8601String()}, bodyText: This is a test post., imagePath: path/to/image.jpg, isSelected: false}');
    });
  });
}
