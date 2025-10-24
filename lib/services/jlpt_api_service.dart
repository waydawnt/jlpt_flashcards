import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/vocabulary_card.dart';

// This class handles all API calls to get JLPT vocabulary data
class JLPTApiService {
  // This is the base URL for the JLPT vocabulary API
  static const String baseUrl = 'https://jlpt-vocab-api.vercel.app';

  // This method fetches vocabulary for a specific JLPT level
  // The 'level' parameter should be like 'N5', 'N4', etc.
  static Future<List<VocabularyCard>> getVocabularyByLevel(String level) async {
    try {
      // Print a debug message to console to track API calls
      print('Fetching vocabulary for level: $level');

      // Create the complete URL by combining base URL with the level
      // Normalize level to the numeric format expected by the API.
      // The API expects numbers like 1..5 where N1 -> 1, N5 -> 5, etc.
      String apiLevel = _normalizeLevel(level);
      String url = '$baseUrl/api/words?level=$apiLevel';

      // Make an HTTP GET request to the API
      // The 'await' keyword waits for the response before continuing
      final response = await http.get(Uri.parse(url));

      // Check if the API request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response body into a Dart Map
        Map<String, dynamic> jsonData = json.decode(response.body);

        // Extract the 'words' array from the JSON response
        List<dynamic> wordsJson = jsonData['words'] ?? [];

        // Convert each JSON word object into a VocabularyCard object
        List<VocabularyCard> vocabularyCards = wordsJson.map((wordJson) {
          return _convertJsonToVocabularyCard(wordJson, level);
        }).toList();

        // Print success message with number of words loaded
        print('Successfully loaded ${vocabularyCards.length} words for $level');

        // Return the list of vocabulary cards
        return vocabularyCards;
      } else {
        // If API request failed, print error and throw exception
        print('Failed to load vocabulary. Status code: ${response.statusCode}');
        throw Exception('Failed to load vocabulary for $level');
      }
    } catch (e) {
      // Catch any errors (network issues, JSON parsing errors, etc.)
      print('Error fetching vocabulary: $e');
      // Re-throw the error so calling code can handle it
      throw Exception('Error fetching vocabulary: $e');
    }
  }

  // Normalize various level formats into the numeric format the API expects.
  // Examples:
  //  - 'N3' -> '3'
  //  - 'JLPT N4' -> '4'
  //  - '3' -> '3' (already numeric)
  // If no numeric part can be found, return the original trimmed string.
  static String _normalizeLevel(String level) {
    String trimmed = level.trim();

    // Find any digits in the string
    final match = RegExp(r"\d+").firstMatch(trimmed);
    if (match != null) {
      return match.group(0)!;
    }

    // Fallback: if it starts with 'N' (e.g. 'N3'), try to take the rest
    if (trimmed.toUpperCase().startsWith('N') && trimmed.length > 1) {
      return trimmed.substring(1);
    }

    // As a last resort return the original trimmed string
    return trimmed;
  }

  // This method gets vocabulary for multiple JLPT levels at once
  // The 'levels' parameter is a list like ['N5', 'N4', 'N3']
  static Future<Map<String, List<VocabularyCard>>>
  getVocabularyForMultipleLevels(List<String> levels) async {
    // Create an empty map to store results for each level
    Map<String, List<VocabularyCard>> result = {};

    // Loop through each level and fetch its vocabulary
    for (String level in levels) {
      try {
        // Get vocabulary for this specific level
        List<VocabularyCard> cards = await getVocabularyByLevel(level);
        // Store the results in our map with level as the key
        result[level] = cards;
      } catch (e) {
        // If one level fails, print error but continue with other levels
        print('Failed to load $level: $e');
        // Store an empty list for this level so app doesn't crash
        result[level] = [];
      }
    }

    // Return the map containing vocabulary for all requested levels
    return result;
  }

  // This private method converts JSON data from API into our VocabularyCard object
  // The underscore (_) makes this method private to this class only
  static VocabularyCard _convertJsonToVocabularyCard(
    Map<String, dynamic> json,
    String level,
  ) {
    // The API sometimes uses different keys. Map them to our model fields.
    // Prefer the newer API keys: 'word', 'furigana', 'romaji', 'meaning', 'example', 'level'
    String word = json['word'] ?? json['kanji'] ?? '';

    // 'furigana' in the API corresponds to our 'hiragana' field
    String reading =
        json['furigana'] ?? json['hiragana'] ?? json['reading'] ?? '';

    // Extract the meaning in English
    String meaning = json['meaning'] ?? '';

    // Some APIs provide example sentences, extract if available
    String example = json['example'] ?? '';

    // If no example provided, create a simple one using the word
    if (example.isEmpty && word.isNotEmpty && meaning.isNotEmpty) {
      example = '$wordを使います。'; // "I use [word]."
    }

    // Convert reading to romaji (Roman letters) - simplified conversion
    String romaji = _convertToRomaji(reading);

    // If API returned numeric level (e.g. level: 3), convert to 'N3'
    String modelLevel = level;
    if (json.containsKey('level')) {
      final apiLevelVal = json['level'];
      if (apiLevelVal is int) {
        modelLevel = 'N${apiLevelVal.toString()}';
      } else if (apiLevelVal is String &&
          RegExp(r"^\d+").hasMatch(apiLevelVal)) {
        modelLevel = 'N${RegExp(r"(\d+)").firstMatch(apiLevelVal)!.group(0)}';
      }
    }

    // Create and return a new VocabularyCard object with the extracted data
    return VocabularyCard(
      kanji: word, // The word in Japanese characters
      hiragana: reading, // How to pronounce it in hiragana (from 'furigana')
      romaji: romaji, // How to pronounce it in Roman letters
      english: meaning, // English translation
      example: example, // Example sentence
      jlptLevel: modelLevel, // Normalized JLPT level like 'N3'
    );
  }

  // This method converts hiragana to romaji (simplified version)
  // In a real app, you might want to use a proper conversion library
  static String _convertToRomaji(String hiragana) {
    // This is a basic conversion map - you can expand this
    Map<String, String> hiraganaToRomaji = {
      'あ': 'a',
      'い': 'i',
      'う': 'u',
      'え': 'e',
      'お': 'o',
      'か': 'ka',
      'き': 'ki',
      'く': 'ku',
      'け': 'ke',
      'こ': 'ko',
      'が': 'ga',
      'ぎ': 'gi',
      'ぐ': 'gu',
      'げ': 'ge',
      'ご': 'go',
      'さ': 'sa',
      'し': 'shi',
      'す': 'su',
      'せ': 'se',
      'そ': 'so',
      'ざ': 'za',
      'じ': 'ji',
      'ず': 'zu',
      'ぜ': 'ze',
      'ぞ': 'zo',
      'た': 'ta',
      'ち': 'chi',
      'つ': 'tsu',
      'て': 'te',
      'と': 'to',
      'だ': 'da',
      'ぢ': 'ji',
      'づ': 'zu',
      'で': 'de',
      'ど': 'do',
      'な': 'na',
      'に': 'ni',
      'ぬ': 'nu',
      'ね': 'ne',
      'の': 'no',
      'は': 'ha',
      'ひ': 'hi',
      'ふ': 'fu',
      'へ': 'he',
      'ほ': 'ho',
      'ば': 'ba',
      'び': 'bi',
      'ぶ': 'bu',
      'べ': 'be',
      'ぼ': 'bo',
      'ぱ': 'pa',
      'ぴ': 'pi',
      'ぷ': 'pu',
      'ぺ': 'pe',
      'ぽ': 'po',
      'ま': 'ma',
      'み': 'mi',
      'む': 'mu',
      'め': 'me',
      'も': 'mo',
      'や': 'ya',
      'ゆ': 'yu',
      'よ': 'yo',
      'ら': 'ra',
      'り': 'ri',
      'る': 'ru',
      'れ': 're',
      'ろ': 'ro',
      'わ': 'wa',
      'を': 'wo',
      'ん': 'n',
    };

    // Convert each hiragana character to romaji
    String result = '';
    for (int i = 0; i < hiragana.length; i++) {
      String char = hiragana[i];
      // If we have a conversion, use it; otherwise keep the original character
      result += hiraganaToRomaji[char] ?? char;
    }

    return result;
  }

  // This method searches for specific words in the API
  static Future<List<VocabularyCard>> searchWords(String query) async {
    try {
      // Create search URL
      String url = '$baseUrl/search?q=$query';

      // Make the API request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> wordsJson = jsonData['results'] ?? [];

        // Convert to VocabularyCard objects
        List<VocabularyCard> results = wordsJson.map((wordJson) {
          return _convertJsonToVocabularyCard(wordJson, 'Search');
        }).toList();

        return results;
      } else {
        throw Exception('Failed to search words');
      }
    } catch (e) {
      throw Exception('Error searching words: $e');
    }
  }
}
