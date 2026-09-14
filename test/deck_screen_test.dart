import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/models/deck.dart';
import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/screens/deck_screen.dart';
import 'package:flashcard/screens/flashcard_detail_screen.dart';

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

  Future<void> pumpDeckScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeckScreen(
          deck: deck,
          flashcardRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Flashcard buildCard({
    String id = 'c1',
    String question = 'Bonjour ?',
    String answer = 'Hello',
  }) {
    final now = DateTime(2026, 1, 1);
    return Flashcard(
      id: id,
      deckId: deck.id,
      question: question,
      answer: answer,
      nextReview: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  testWidgets('Deck screen shows empty state', (tester) async {
    await pumpDeckScreen(tester);

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Aucune carte. Créez-en une !'), findsOneWidget);
    expect(find.text('0 carte'), findsOneWidget);
  });

  testWidgets('Deck screen lists flashcards', (tester) async {
    await repository.save(buildCard());
    await repository.save(
      buildCard(
        id: 'c2',
        question: 'Merci ?',
        answer: 'Thank you',
      ),
    );

    await pumpDeckScreen(tester);

    expect(find.text('Bonjour ?'), findsOneWidget);
    expect(find.text('Merci ?'), findsOneWidget);
    expect(find.text('2 cartes'), findsOneWidget);
  });

  testWidgets('Creates a flashcard via dialog', (tester) async {
    await pumpDeckScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Au revoir ?');
    await tester.enterText(find.byType(TextFormField).at(1), 'Goodbye');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Au revoir ?'), findsOneWidget);
    expect(find.text('1 carte'), findsOneWidget);
  });

  testWidgets('Edits a flashcard via dialog', (tester) async {
    await repository.save(buildCard());
    await pumpDeckScreen(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Salut ?');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Salut ?'), findsOneWidget);
    expect(find.text('Bonjour ?'), findsNothing);
  });

  testWidgets('Deletes a flashcard', (tester) async {
    await repository.save(buildCard());
    await pumpDeckScreen(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour ?'), findsNothing);
    expect(find.text('Aucune carte. Créez-en une !'), findsOneWidget);
  });

  testWidgets('Opens the flashcard detail and flips to the answer',
      (tester) async {
    await repository.save(buildCard());
    await pumpDeckScreen(tester);

    await tester.tap(find.text('Bonjour ?'));
    await tester.pumpAndSettle();

    expect(find.byType(FlashcardDetailScreen), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);

    await tester.tap(find.text('Voir la réponse'));
    await tester.pumpAndSettle();

    expect(find.text('Réponse'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}