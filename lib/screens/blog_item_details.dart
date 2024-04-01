import 'package:flutter/material.dart';
import 'package:drive_memo/models/blog_item.dart';
import 'package:drive_memo/screens/edit_blog_item_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Convert to StatefulWidget
class BlogItemDetails extends StatefulWidget {
  final BlogItem blogItem;

  const BlogItemDetails({Key? key, required this.blogItem}) : super(key: key);

  @override
  _BlogItemDetailsState createState() => _BlogItemDetailsState();
}

// State class for BlogItemDetails
class _BlogItemDetailsState extends State<BlogItemDetails> {
  // Use widget.blogItem to access the BlogItem object

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blogItem.title), // Use widget.blogItem to access the BlogItem object
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBlogItem(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editBlogItem(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${widget.blogItem.title}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              Text('Date: ${widget.blogItem.date.toLocal()}'),
              const SizedBox(height: 16.0),
              Text('Description: ${widget.blogItem.bodyText}'),
              const SizedBox(height: 16.0),
              if (widget.blogItem.imagePath != null) Image.file(File(widget.blogItem.imagePath!)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editBlogItem(BuildContext context) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBlogItemScreen(widget.blogItem)),
    );

    // If EditBlogItemScreen indicates that an update was made, you can use setState to update the UI here
    if (result == true) {
      setState(() {
        // This is just a placeholder action.
        // The actual update logic will depend on how you manage state.
      });
    }
  }

  void _shareBlogItem(BuildContext context) {
    Share.share(
      'Check out this blog post:\n\nTitle: ${widget.blogItem.title}\nDate: ${widget.blogItem.date.toIso8601String()}\nBody: ${widget.blogItem.bodyText}',
      subject: 'Blog Post: ${widget.blogItem.title}',
    );
  }
}
