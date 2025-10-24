class VocabularyCard {
  final String kanji;
  final String hiragana;
  final String romaji;
  final String english;
  final String example;
  final String jlptLevel;
  bool isLearned;
  int reviewCount;
  DateTime? lastReviewDate;

  VocabularyCard({
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.english,
    required this.example,
    required this.jlptLevel,
    this.isLearned = false,
    this.reviewCount = 0,
    this.lastReviewDate,
  });

  Map<String, dynamic> toJSON() {
    return {
      'kanji': kanji,
      'hiragana': hiragana,
      'romaji': romaji,
      'english': english,
      'example': example,
      'jlptLevel': jlptLevel,
      'isLearned': isLearned,
      'reviewCount': reviewCount,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
    };
  }

  factory VocabularyCard.fromJSON(Map<String, dynamic> json) {
    return VocabularyCard(
      kanji: json['kanji'],
      hiragana: json['hiragana'],
      romaji: json['romaji'],
      english: json['english'],
      example: json['example'],
      jlptLevel: json['jlptLevel'],
      isLearned: json['isLearned'] ?? false,
      reviewCount: json['reviewCount'] ?? 0,
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'])
          : null,
    );
  }
}
