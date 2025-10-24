import 'package:flutter/material.dart';
import 'flashcard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JLPT Flashcards'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to JLPT Flashcards',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn Japanese vocabulary from N5 to N1',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Create cards for all JLPT levels
                _buildLevelCard(
                  context,
                  'JLPT N5',
                  'Beginner Level',
                  Colors.green,
                ),
                const SizedBox(height: 15),
                _buildLevelCard(
                  context,
                  'JLPT N4',
                  'Elementary Level',
                  Colors.lightGreen,
                ),
                const SizedBox(height: 15),
                _buildLevelCard(
                  context,
                  'JLPT N3',
                  'Intermediate Level',
                  Colors.orange,
                ),
                const SizedBox(height: 15),
                _buildLevelCard(
                  context,
                  'JLPT N2',
                  'Pre-Advanced Level',
                  Colors.deepOrange,
                ),
                const SizedBox(height: 15),
                _buildLevelCard(
                  context,
                  'JLPT N1',
                  'Advanced Level',
                  Colors.red,
                ),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Tip: Start with N5 and work your way up!\nStudy 15-20 minutes daily for best results.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This method creates a card for each JLPT level
  Widget _buildLevelCard(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        // When user taps the card, navigate to flashcard screen for that level
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlashcardScreen(level: title),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon on the left
              Icon(Icons.quiz, size: 30, color: color),
              const SizedBox(width: 15),
              // Text in the middle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Arrow on the right
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
