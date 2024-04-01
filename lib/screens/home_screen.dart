import 'package:flutter/material.dart';
import 'package:drive_memo/models/blog_item.dart';
import 'package:drive_memo/screens/blog_item_details.dart';
import 'package:drive_memo/screens/create_blog_item_screen.dart';
import 'package:drive_memo/database/database_helper.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<BlogItem>> blogItemsFuture;
  final Set<int?> _selectedItems = {};
  bool _isSelectionModeEnabled = false;
  bool _isSearching = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    blogItemsFuture = fetchBlogItems();
  }

  void _refreshBlogItems() {
    setState(() {
      blogItemsFuture = fetchBlogItems();
    });
  }

  Future<List<BlogItem>> fetchBlogItems() async {
    final List<BlogItem> blogItems = await DatabaseHelper.instance.getBlogItems();
    if (!_isSearching || _searchQuery.isEmpty) {
      return blogItems;
    }
    return blogItems.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) || item.bodyText.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void toggleSelectionMode() {
    setState(() {
      _isSelectionModeEnabled = !_isSelectionModeEnabled;
      _selectedItems.clear();
    });
  }

  void toggleItemSelection(int? id) {
    setState(() {
      if (_selectedItems.contains(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems.add(id);
      }
    });
  }

  void _deleteSelectedItems() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Selected Items"),
          content: Text("Are you sure you want to delete these items?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                for (var itemId in _selectedItems) {
                  await DatabaseHelper.instance.deleteBlogItem(itemId!);
                }
                _selectedItems.clear();
                _refreshBlogItems();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              blogItemsFuture = fetchBlogItems();
            });
          },
          decoration: InputDecoration(
            hintText: "Search...",
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text('Blog Home'),
        actions: [
          if (!_isSelectionModeEnabled)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = "";
                  blogItemsFuture = fetchBlogItems();
                });
              },
            ),
          if (_isSelectionModeEnabled || _selectedItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedItems,
            ),
          if (_isSelectionModeEnabled)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: toggleSelectionMode,
            ),
          if (!_isSelectionModeEnabled && _selectedItems.isEmpty)
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: toggleSelectionMode,
            ),
        ],
      ),
      body: FutureBuilder<List<BlogItem>>(
        future: blogItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final blogItems = snapshot.data!;
            return ListView.builder(
              itemCount: blogItems.length,
              itemBuilder: (context, index) {
                return buildBlogItemCard(blogItems[index]);
              },
            );
          } else {
            return const Center(child: Text('No blog items available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateBlogItemScreen()),
          );
          if (result == true) {
            _refreshBlogItems();
          }
        },
        tooltip: 'Create Blog Item',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildBlogItemCard(BlogItem item) {
    final formattedDate = DateFormat.yMMMd().format(item.date);
    final bool isSelected = _selectedItems.contains(item.id);
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      color: isSelected ? Colors.blue[100] : null,
      child: ListTile(
        onTap: () {
          if (_isSelectionModeEnabled) {
            toggleItemSelection(item.id);
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlogItemDetails(blogItem: item),
            ));
          }
        },
        title: Text(item.title),
        subtitle: Text(formattedDate),
        leading: _isSelectionModeEnabled
            ? Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            toggleItemSelection(item.id);
          },
        )
            : null,
        trailing: !_isSelectionModeEnabled
            ? IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            // This can also be extracted to a method if the deletion logic gets more complex
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Blog Item"),
                  content: Text("Are you sure you want to delete this item?"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Dismiss the dialog
                        await DatabaseHelper.instance.deleteBlogItem(item.id!); // Proceed with deletion
                        _refreshBlogItems();
                      },
                    ),
                  ],
                );
              },
            );
          },
        )
            : null,
      ),
    );
  }
}
