// Import the API service we just created
import '../services/jlpt_api_service.dart';
import '../models/vocabulary_card.dart';

// This class now fetches data from API instead of hardcoded data
class VocabularyData {
  // Cache to store downloaded vocabulary so we don't re-download every time
  static final Map<String, List<VocabularyCard>> _cache = {};

  // This method gets N5 vocabulary from the API
  static Future<List<VocabularyCard>> getN5Vocabulary() async {
    // Check if we already have N5 data in cache
    if (_cache.containsKey('N5') && _cache['N5']!.isNotEmpty) {
      print('Returning cached N5 vocabulary');
      return _cache['N5']!;
    }

    try {
      // If not in cache, fetch from API
      print('Fetching N5 vocabulary from API...');
      List<VocabularyCard> vocabulary =
          await JLPTApiService.getVocabularyByLevel('N5');

      // Store in cache for future use
      _cache['N5'] = vocabulary;

      return vocabulary;
    } catch (e) {
      // If API fails, return some fallback data so app doesn't crash
      print('Failed to fetch N5 vocabulary, returning fallback data: $e');
      return _getFallbackN5Data();
    }
  }

  // This method gets N4 vocabulary from the API
  static Future<List<VocabularyCard>> getN4Vocabulary() async {
    // Same pattern as N5 - check cache first
    if (_cache.containsKey('N4') && _cache['N4']!.isNotEmpty) {
      print('Returning cached N4 vocabulary');
      return _cache['N4']!;
    }

    try {
      print('Fetching N4 vocabulary from API...');
      List<VocabularyCard> vocabulary =
          await JLPTApiService.getVocabularyByLevel('N4');
      _cache['N4'] = vocabulary;
      return vocabulary;
    } catch (e) {
      print('Failed to fetch N4 vocabulary, returning fallback data: $e');
      return _getFallbackN4Data();
    }
  }

  // This method gets N3 vocabulary from the API
  static Future<List<VocabularyCard>> getN3Vocabulary() async {
    if (_cache.containsKey('N3') && _cache['N3']!.isNotEmpty) {
      return _cache['N3']!;
    }

    try {
      List<VocabularyCard> vocabulary =
          await JLPTApiService.getVocabularyByLevel('N3');
      _cache['N3'] = vocabulary;
      return vocabulary;
    } catch (e) {
      print('Failed to fetch N3 vocabulary: $e');
      return _getFallbackN3Data();
    }
  }

  // This method gets N2 vocabulary from the API
  static Future<List<VocabularyCard>> getN2Vocabulary() async {
    if (_cache.containsKey('N2') && _cache['N2']!.isNotEmpty) {
      return _cache['N2']!;
    }

    try {
      List<VocabularyCard> vocabulary =
          await JLPTApiService.getVocabularyByLevel('N2');
      _cache['N2'] = vocabulary;
      return vocabulary;
    } catch (e) {
      print('Failed to fetch N2 vocabulary: $e');
      return [];
    }
  }

  // This method gets N1 vocabulary from the API
  static Future<List<VocabularyCard>> getN1Vocabulary() async {
    if (_cache.containsKey('N1') && _cache['N1']!.isNotEmpty) {
      return _cache['N1']!;
    }

    try {
      List<VocabularyCard> vocabulary =
          await JLPTApiService.getVocabularyByLevel('N1');
      _cache['N1'] = vocabulary;
      return vocabulary;
    } catch (e) {
      print('Failed to fetch N1 vocabulary: $e');
      return [];
    }
  }

  // This method gets vocabulary for any level
  static Future<List<VocabularyCard>> getVocabularyByLevel(String level) async {
    switch (level.toUpperCase()) {
      case 'N5':
      case 'JLPT N5':
        return await getN5Vocabulary();
      case 'N4':
      case 'JLPT N4':
        return await getN4Vocabulary();
      case 'N3':
      case 'JLPT N3':
        return await getN3Vocabulary();
      case 'N2':
      case 'JLPT N2':
        return await getN2Vocabulary();
      case 'N1':
      case 'JLPT N1':
        return await getN1Vocabulary();
      default:
        throw Exception('Unknown JLPT level: $level');
    }
  }

  // This method clears the cache if needed
  static void clearCache() {
    _cache.clear();
    print('Vocabulary cache cleared');
  }

  // Fallback data in case API is not available
  static List<VocabularyCard> _getFallbackN5Data() {
    return [
      VocabularyCard(
        kanji: '時間',
        hiragana: 'じかん',
        romaji: 'jikan',
        english: 'time',
        example: '[translate:時間がありません]。',
        jlptLevel: 'N5',
      ),
      VocabularyCard(
        kanji: '学校',
        hiragana: 'がっこう',
        romaji: 'gakkou',
        english: 'school',
        example: '[translate:学校に行きます]。',
        jlptLevel: 'N5',
      ),
      VocabularyCard(
        kanji: '友達',
        hiragana: 'ともだち',
        romaji: 'tomodachi',
        english: 'friend',
        example: '[translate:友達と話します]。',
        jlptLevel: 'N5',
      ),
    ];
  }

  static List<VocabularyCard> _getFallbackN4Data() {
    return [
      VocabularyCard(
        kanji: '経験',
        hiragana: 'けいけん',
        romaji: 'keiken',
        english: 'experience',
        example: '[translate:いい経験でした]。',
        jlptLevel: 'N4',
      ),
      VocabularyCard(
        kanji: '文化',
        hiragana: 'ぶんか',
        romaji: 'bunka',
        english: 'culture',
        example: '[translate:日本の文化]。',
        jlptLevel: 'N4',
      ),
    ];
  }

  static List<VocabularyCard> _getFallbackN3Data() {
    return [
      VocabularyCard(
        kanji: '技術',
        hiragana: 'ぎじゅつ',
        romaji: 'gijutsu',
        english: 'technology',
        example: '[translate:新しい技術]。',
        jlptLevel: 'N3',
      ),
    ];
  }
}
