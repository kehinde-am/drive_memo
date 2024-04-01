class BlogItem {
  int? id; // Unique identifier for the blog item
  String title; // Title of the blog item
  DateTime date; // Publication date of the blog item
  String bodyText; // Body text of the blog item
  String? imagePath; // Optional path to an image associated with the blog item
  bool isSelected; // For UI selection tracking

  BlogItem({
    this.id,
    required this.title,
    required this.date,
    required this.bodyText,
    this.imagePath,
    this.isSelected = false, // Default to false, indicating not selected
  });

  // Converts a BlogItem object into a map. Note: isSelected is not included because it's only for UI state.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'body_text': bodyText,
      'image_path': imagePath,
    };
  }

  // Constructs a BlogItem from a map. Note: isSelected is not included because it's not stored in the database.
  BlogItem.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        date = DateTime.parse(map['date']),
        bodyText = map['body_text'],
        imagePath = map['image_path'],
        isSelected = false; // Default to false when constructing from a map

  @override
  String toString() {
    return 'BlogItem{id: $id, title: $title, date: ${date.toIso8601String()}, bodyText: $bodyText, imagePath: $imagePath, isSelected: $isSelected}';
  }
}
