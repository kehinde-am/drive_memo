import 'package:flutter/material.dart';
import 'package:drive_memo/screens/home_screen.dart';
import 'package:drive_memo/screens/edit_blog_item_screen.dart';
import 'package:drive_memo/screens/create_blog_item_screen.dart';
import 'package:drive_memo/screens/blog_item_list.dart';
import 'package:drive_memo/screens/splash_screen.dart'; // Import the SplashScreen
import 'models/blog_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveMemo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Changed the initial route to SplashScreen
      home: const SplashScreen(),
      routes: {
        // When navigating to the "/" route, build the HomeScreen widget.
        '/home': (context) => const HomeScreen(),
        // When navigating to the "/create" route, build the CreateBlogItemScreen widget.
        '/create': (context) => const CreateBlogItemScreen(),
        // Add more named routes as needed
      },
      onGenerateRoute: (settings) {
        // Handle '/edit' route
        if (settings.name == '/edit') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('blogItem') && args['blogItem'] is BlogItem) {
            return MaterialPageRoute(
              builder: (context) => EditBlogItemScreen(args['blogItem'] as BlogItem),
            );
          }
        }
        // Handle '/blogItemList' route
        else if (settings.name == '/blogItemList') {
          return MaterialPageRoute(
            builder: (context) => const BlogItemList(),
          );
        }
        // Return null for any other cases which aren't handled
        return null;
      },
    );
  }
}
