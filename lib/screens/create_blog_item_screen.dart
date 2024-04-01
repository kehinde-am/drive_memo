import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:drive_memo/database/database_helper.dart';
import 'package:drive_memo/models/blog_item.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class CreateBlogItemScreen extends StatefulWidget {
  const CreateBlogItemScreen({super.key});

  @override
  _CreateBlogItemScreenState createState() => _CreateBlogItemScreenState();
}

class _CreateBlogItemScreenState extends State<CreateBlogItemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  File? _image;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Blog Item'),
      ),
      body: SafeArea( // Ensure the content is within the safe area
        child: SingleChildScrollView( // Makes the view scrollable
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
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: () {
                    // Prevent the default keyboard from appearing
                    FocusScope.of(context).requestFocus(new FocusNode());
                    // Show Date Picker here
                    _selectDate(context);
                  },
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: _getImage,
                  child: _image == null
                      ? Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.camera_alt, size: 40),
                    ),
                  )
                      : Image.file(
                    _image!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _bodyTextController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Body Text'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_dateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date')),
                      );
                      return;
                    }

                    DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);

                    BlogItem newBlogItem = BlogItem(
                      title: _titleController.text,
                      date: selectedDate,
                      bodyText: _bodyTextController.text,
                      imagePath: _image?.path,
                    );

                    print('New Blog Item: $newBlogItem');

                    try {
                      final Database db = await DatabaseHelper.instance.database;
                      await db.insert('blog_items', newBlogItem.toMap());
                      Navigator.pop(context, true); // Return true to indicate that an item was created
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save blog item: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
