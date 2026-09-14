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
    const seed = Color(0xFF6C63FF);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'FlashCard Engine',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F5FC),
        textTheme: Typography.material2021()
            .black
            .apply(fontFamily: 'Roboto')
            .copyWith(
              headlineSmall: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              titleLarge: const TextStyle(fontWeight: FontWeight.w700),
              titleMedium: const TextStyle(fontWeight: FontWeight.w600),
            ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 2,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          titleTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      home: HomeScreen(
        repository: deckRepository ?? HiveDeckRepository(),
        flashcardRepository: flashcardRepository ?? HiveFlashcardRepository(),
      ),
    );
  }
}
