import '../models/vocabulary_card.dart';

class SpacedRepetition {
  // Calculate next review date based on performance
  static DateTime calculateNextReview(VocabularyCard card, bool wasCorrect) {
    DateTime now = DateTime.now();
    int interval = 1; // days

    if (wasCorrect) {
      // Increase interval based on how many times reviewed correctly
      switch (card.reviewCount) {
        case 0:
        case 1:
          interval = 1; // Next day
          break;
        case 2:
          interval = 3; // 3 days
          break;
        case 3:
          interval = 7; // 1 week
          break;
        case 4:
          interval = 14; // 2 weeks
          break;
        default:
          interval = 30; // 1 month
      }
    } else {
      // If incorrect, review again soon
      interval = 1;
    }

    return now.add(Duration(days: interval));
  }

  // Get cards that need review today
  static List<VocabularyCard> getCardsForReview(List<VocabularyCard> allCards) {
    DateTime today = DateTime.now();
    List<VocabularyCard> reviewCards = [];

    for (VocabularyCard card in allCards) {
      if (card.lastReviewDate == null) {
        // Never reviewed, add to review
        reviewCards.add(card);
      } else {
        DateTime nextReview = calculateNextReview(
          card,
          true,
        ); // Assume last was correct for scheduling
        if (today.isAfter(nextReview) || today.isAtSameMomentAs(nextReview)) {
          reviewCards.add(card);
        }
      }
    }

    return reviewCards;
  }

  // Shuffle cards for better learning
  static List<VocabularyCard> shuffleCards(List<VocabularyCard> cards) {
    List<VocabularyCard> shuffled = List.from(cards);
    shuffled.shuffle();
    return shuffled;
  }
}
