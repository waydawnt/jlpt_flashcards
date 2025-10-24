import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary_card.dart';
import '../data/vocabulary_data.dart';
import '../services/progress_manager.dart';
import '../services/spaced_repetition.dart';

class FlashcardScreen extends StatefulWidget {
  final String level;

  const FlashcardScreen({super.key, required this.level});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Variables to store our data
  List<VocabularyCard> allCards = [];
  List<VocabularyCard> reviewCards = [];
  int currentIndex = 0;
  FlutterTts flutterTts = FlutterTts();
  bool showAnswer = false;
  int studyStreak = 0;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  // Loading state variables
  bool isLoading = true;
  String loadingMessage = 'Loading vocabulary...';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadCards();
  }

  // Initialize text-to-speech
  void _initTts() async {
    try {
      // Check available languages
      List<dynamic> languages = await flutterTts.getLanguages;
      print('Available languages: $languages');

      // Check if Japanese is available
      bool isJapaneseAvailable = await flutterTts.isLanguageAvailable('ja-JP');
      print('Japanese available: $isJapaneseAvailable');

      if (!isJapaneseAvailable) {
        print('WARNING: Japanese TTS not available on this device!');
      }

      await flutterTts.setLanguage('ja-JP');
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.awaitSpeakCompletion(true);

      // Add handlers for debugging
      flutterTts.setStartHandler(() {
        print('TTS Started');
      });

      flutterTts.setCompletionHandler(() {
        print('TTS Completed');
      });

      flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
      });
    } catch (e) {
      print('TTS initialization error: $e');
    }
  }

  // void _initTts() async {
  //   await flutterTts.setLanguage('ja-JP');
  //   await flutterTts.setSpeechRate(0.5);
  // }

  // This method loads vocabulary cards from the API
  void _loadCards() async {
    setState(() {
      isLoading = true;
      loadingMessage = 'Connecting to vocabulary database...';
      errorMessage = null;
    });

    try {
      // Update loading message
      setState(() {
        loadingMessage = 'Downloading ${widget.level} vocabulary...';
      });

      // Get vocabulary from API (this is an async operation)
      List<VocabularyCard> cards = await VocabularyData.getVocabularyByLevel(
        widget.level,
      );

      // Update loading message
      setState(() {
        loadingMessage = 'Processing vocabulary data...';
      });

      // Store the loaded cards
      allCards = cards;

      // Load saved progress
      await _loadProgress(); // <-- The call to the fixed method

      // Update loading message
      setState(() {
        loadingMessage = 'Preparing your study session...';
      });

      // Small delay to show the final loading message
      await Future.delayed(const Duration(milliseconds: 500));

      // Loading complete
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle any errors that occur during loading
      print('Error loading cards: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load vocabulary: ${e.toString()}';
      });
    }
  }

  // Load user's progress from storage
  Future<void> _loadProgress() async {
    try {
      // Load saved progress
      List<VocabularyCard> savedCards = await ProgressManager.loadProgress();

      if (savedCards.isNotEmpty) {
        // Merge saved progress with loaded cards
        for (int i = 0; i < allCards.length; i++) {
          // FIX APPLIED HERE: Removed nullable '?' as orElse guarantees a value.
          VocabularyCard savedCard = savedCards.firstWhere(
            (card) => card.kanji == allCards[i].kanji,
            orElse: () => allCards[i], // Guarantees a non-null return
          );

          // Simplified assignment, as 'savedCard' is now non-nullable
          allCards[i] = savedCard;
        }
      }

      // Get cards for today's review using spaced repetition
      reviewCards = SpacedRepetition.getCardsForReview(allCards);
      if (reviewCards.isEmpty) {
        reviewCards = allCards
            .take(20)
            .toList(); // Show first 20 if no cards due for review
      }
      reviewCards = SpacedRepetition.shuffleCards(reviewCards);

      // Load study streak
      studyStreak = await ProgressManager.getStudyStreak();
    } catch (e) {
      print('Error loading progress: $e');
      // Continue with default settings if progress loading fails
      reviewCards = allCards.take(20).toList();
      studyStreak = 0;
    }
  }

  // Rest of your flashcard methods remain the same...
  void _speak(String text) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔊 _speak() CALLED');
    print('📝 Text: "$text"');
    print('📊 Text length: ${text.length}');

    try {
      if (text.trim().isEmpty) {
        print('❌ Empty text');
        return;
      }

      print('⏳ Setting language to ja-JP...');
      await flutterTts.setLanguage('ja-JP');

      print('🎤 Calling speak()...');
      var result = await flutterTts.speak(text);

      print('✅ Speak result: $result');

      if (result == 1) {
        print('✅ TTS SUCCESS');
      } else {
        print('❌ TTS FAILED: $result');
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // void _speak(String text) async {
  //   await flutterTts.speak(text);
  // }

  void _markCardResult(bool isCorrect) async {
    if (reviewCards.isEmpty) return;

    VocabularyCard currentCard = reviewCards[currentIndex];

    await ProgressManager.updateCardProgress(currentCard, isCorrect);
    await ProgressManager.updateStudyStreak();
    await ProgressManager.saveProgress(allCards);

    _nextCard();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct! 🎉' : 'Try again! 💪'),
        backgroundColor: isCorrect ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _nextCard() {
    setState(() {
      if (currentIndex < reviewCards.length - 1) {
        currentIndex++;
      } else {
        _showCompletionDialog();
        return;
      }
      showAnswer = false;
    });

    if (cardKey.currentState?.isFront == false) {
      cardKey.currentState?.toggleCard();
    }
  }

  void _previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = reviewCards.length - 1;
      }
      showAnswer = false;
    });

    if (cardKey.currentState?.isFront == false) {
      cardKey.currentState?.toggleCard();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Great Job! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You\'ve completed today\'s review session!'),
              const SizedBox(height: 10),
              Text('Study Streak: $studyStreak days'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // Retry loading if there was an error
  void _retryLoading() {
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while fetching data
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.level),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                loadingMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'This may take a few moments...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show error screen if loading failed
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.level),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _retryLoading,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state if no cards available
    if (reviewCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.level)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text('All caught up for today!', style: TextStyle(fontSize: 24)),
              Text('Come back tomorrow for more practice.'),
            ],
          ),
        ),
      );
    }

    // Show the actual flashcard interface
    VocabularyCard currentCard = reviewCards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '🔥 $studyStreak',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              print('🔴 SPEAKER BUTTON CLICKED');
              print('📋 reviewCards.length: ${reviewCards.length}');
              print('📌 currentIndex: $currentIndex');

              if (reviewCards.isEmpty) {
                print('❌ No cards loaded!');
                return;
              }

              print('🎯 currentCard.hiragana: ${currentCard.hiragana}');
              _speak(currentCard.hiragana);
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.volume_up),
          //   onPressed: () => _speak(currentCard.hiragana),
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${currentIndex + 1} / ${reviewCards.length}'),
                  Text(
                    'Learned: ${allCards.where((c) => c.isLearned).length}/${allCards.length}',
                  ),
                ],
              ),
            ),

            LinearProgressIndicator(
              value: (currentIndex + 1) / reviewCards.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FlipCard(
                    key: cardKey,
                    direction: FlipDirection.HORIZONTAL,
                    onFlipDone: (isFront) {
                      setState(() {
                        if (!isFront) {
                          showAnswer = true;
                        } else {
                          showAnswer = false;
                        }
                      });
                    },
                    front: _buildCardFront(currentCard),
                    back: _buildCardBack(currentCard),
                  ),
                ),
              ),
            ),

            if (!showAnswer)
              const Padding(
                padding: EdgeInsetsGeometry.only(top: 8),
                child: Text(
                  'Flip the card to check your answer',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

            if (showAnswer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _markCardResult(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Incorrect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _markCardResult(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Correct'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _previousCard,
                    child: const Icon(Icons.arrow_back),
                  ),
                  ElevatedButton(
                    onPressed: () => _speak(currentCard.hiragana),
                    child: const Icon(Icons.volume_up),
                  ),
                  ElevatedButton(
                    onPressed: _nextCard,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card building methods remain the same...
  Widget _buildCardFront(VocabularyCard card) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Card(
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (card.isLearned)
                const Icon(Icons.star, color: Colors.yellow, size: 30),
              Text(
                card.kanji,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                card.hiragana,
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap to see meaning',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(VocabularyCard card) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Card(
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.english,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                card.romaji,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                card.example,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Reviewed: ${card.reviewCount} times',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
