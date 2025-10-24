import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const JLPTFlashcardsApp());
}

class JLPTFlashcardsApp extends StatelessWidget {
  const JLPTFlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JLPT Flashcards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansCJK',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
