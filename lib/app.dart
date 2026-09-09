import 'package:flutter/material.dart';

import 'repositories/deck_repository.dart';
import 'repositories/hive_deck_repository.dart';
import 'screens/home_screen.dart';

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key, this.deckRepository});

  final DeckRepository? deckRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashCard Engine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(repository: deckRepository ?? HiveDeckRepository()),
    );
  }
}
