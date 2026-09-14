import 'package:flutter/material.dart';

import 'repositories/deck_repository.dart';
import 'repositories/flashcard_repository.dart';
import 'repositories/hive_deck_repository.dart';
import 'repositories/hive_flashcard_repository.dart';
import 'screens/home_screen.dart';

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({
    super.key,
    this.deckRepository,
    this.flashcardRepository,
  });

  final DeckRepository? deckRepository;
  final FlashcardRepository? flashcardRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashCard Engine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(
        repository: deckRepository ?? HiveDeckRepository(),
        flashcardRepository: flashcardRepository ?? HiveFlashcardRepository(),
      ),
    );
  }
}
