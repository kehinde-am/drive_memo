import 'package:flutter/material.dart';
import 'package:drive_memo/models/blog_item.dart';
import 'package:drive_memo/database/database_helper.dart';

class BlogItemList extends StatelessWidget {
  const BlogItemList({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Items'),
      ),
      body: FutureBuilder<List<BlogItem>>(
        future: DatabaseHelper.instance.getBlogItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.date.toString()),
                  onTap: () {
                    // Navigate to detail screen or perform another action
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
