import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/models/deck.dart';
import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/screens/study_screen.dart';
import 'package:flashcard/services/spaced_repetition_service.dart';

import 'fakes/fake_flashcard_repository.dart';

void main() {
  late FakeFlashcardRepository repository;
  late Deck deck;

  setUp(() {
    repository = FakeFlashcardRepository();
    final now = DateTime(2026, 1, 1);
    deck = Deck(
      id: 'deck-1',
      title: 'Français',
      description: 'Vocabulaire',
      createdAt: now,
      updatedAt: now,
    );
  });

  Flashcard buildCard({
    String id = 'c1',
    String question = 'Bonjour ?',
    String answer = 'Hello',
    DateTime? nextReview,
  }) {
    final now = DateTime(2026, 1, 1);
    return Flashcard(
      id: id,
      deckId: deck.id,
      question: question,
      answer: answer,
      nextReview: nextReview ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpStudy(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudyScreen(
          deck: deck,
          flashcardRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Shows only due cards', (tester) async {
    await repository.save(buildCard());
    await repository.save(
      buildCard(
        id: 'c2',
        question: 'Future ?',
        answer: 'Avenir',
        nextReview: DateTime(2026, 12, 31),
      ),
    );

    await pumpStudy(tester);

    expect(find.text('Bonjour ?'), findsOneWidget);
    expect(find.text('Future ?'), findsNothing);
    expect(find.text('Carte 1 / 1'), findsOneWidget);
  });

  testWidgets('Shows empty state when no card is due', (tester) async {
    await pumpStudy(tester);

    expect(find.text('Aucune carte à réviser pour le moment.'), findsOneWidget);
  });

  testWidgets('Reveals the answer then rates the card', (tester) async {
    await repository.save(buildCard());
    await pumpStudy(tester);

    expect(find.text('Hello'), findsNothing);
    await tester.tap(find.text('Voir la réponse'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    await tester.tap(find.text('Bien'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée !'), findsOneWidget);

    final card = await repository.getById('c1');
    expect(card, isNotNull);
    expect(card!.repetitions, 1);
    expect(card.interval, 1);
    expect(card.easeFactor, SpacedRepetitionService.initialEaseFactor);
  });
}