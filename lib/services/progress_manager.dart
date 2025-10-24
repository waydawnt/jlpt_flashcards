import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_card.dart';

class ProgressManager {
  static const String _progressKey = 'vocabulary_progress';
  static const String _streakKey = 'study_streak';
  static const String _lastStudyDateKey = 'last_study_date';

  // Save progress
  static Future<void> saveProgress(List<VocabularyCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> progressList = cards
        .map((card) => jsonEncode(card.toJSON()))
        .toList();
    await prefs.setStringList(_progressKey, progressList);
  }

  // Load progress
  static Future<List<VocabularyCard>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? progressList = prefs.getStringList(_progressKey);

    if (progressList == null) return [];

    return progressList.map((cardJson) {
      Map<String, dynamic> cardMap = jsonDecode(cardJson);
      return VocabularyCard.fromJSON(cardMap);
    }).toList();
  }

  // Update study streak
  static Future<void> updateStudyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();
    String? lastStudyDateString = prefs.getString(_lastStudyDateKey);

    if (lastStudyDateString != null) {
      DateTime lastStudyDate = DateTime.parse(lastStudyDateString);
      int daysDifference = today.difference(lastStudyDate).inDays;

      if (daysDifference == 1) {
        // Consecutive day, increment streak
        int currentStreak = prefs.getInt(_streakKey) ?? 0;
        await prefs.setInt(_streakKey, currentStreak + 1);
      } else if (daysDifference > 1) {
        // Broke streak, reset to 1
        await prefs.setInt(_streakKey, 1);
      }
      // If daysDifference == 0, same day, don't change streak
    } else {
      // First time studying
      await prefs.setInt(_streakKey, 1);
    }

    await prefs.setString(_lastStudyDateKey, today.toIso8601String());
  }

  // Get study streak
  static Future<int> getStudyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // Mark card as learned/not learned
  static Future<void> updateCardProgress(
    VocabularyCard card,
    bool isCorrect,
  ) async {
    card.reviewCount++;
    card.lastReviewDate = DateTime.now();

    if (isCorrect) {
      card.isLearned =
          card.reviewCount >= 3; // Consider learned after 3 correct reviews
    } else {
      card.isLearned = false;
    }
  }
}
