import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drive_memo/models/blog_item.dart';
import 'package:drive_memo/database/database_helper.dart';

class EditBlogItemScreen extends StatefulWidget {
  final BlogItem blogItem;

  const EditBlogItemScreen(this.blogItem, {super.key});

  @override
  _EditBlogItemScreenState createState() => _EditBlogItemScreenState();
}

class _EditBlogItemScreenState extends State<EditBlogItemScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyTextController;
  File? _image; // To hold the image file

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blogItem.title);
    _bodyTextController = TextEditingController(text: widget.blogItem.bodyText);
    if (widget.blogItem.imagePath != null) {
      _image = File(widget.blogItem.imagePath!); // Load the current image if it exists
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update _image with the new image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog Item'),
      ),
      body: SingleChildScrollView( // Wrap in SingleChildScrollView to prevent overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _bodyTextController,
                decoration: const InputDecoration(labelText: 'Body Text'),
                maxLines: null, // Allow multiline text input
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: _pickImage,
                child: _image != null
                    ? Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Update the blog item's title, bodyText, and possibly imagePath
                  widget.blogItem.title = _titleController.text;
                  widget.blogItem.bodyText = _bodyTextController.text;
                  widget.blogItem.imagePath = _image?.path;

                  // Call DatabaseHelper to update the blog item
                  await DatabaseHelper.instance.updateBlogItem(widget.blogItem);
                  // Pop the screen and return true to indicate the blog item was updated
                  Navigator.pop(context, true);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyTextController.dispose();
    super.dispose();
  }
}
