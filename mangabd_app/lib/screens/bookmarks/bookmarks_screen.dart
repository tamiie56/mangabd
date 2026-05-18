import 'package:flutter/material.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Text(
          'Bookmarks',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }
}