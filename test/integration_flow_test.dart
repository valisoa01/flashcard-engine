import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/app.dart';
import 'package:flashcard/models/deck.dart';
import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/screens/deck_screen.dart';
import 'package:flashcard/screens/study_screen.dart';

import 'fakes/fake_deck_repository.dart';
import 'fakes/fake_flashcard_repository.dart';

void main() {
  late FakeDeckRepository deckRepository;
  late FakeFlashcardRepository flashcardRepository;

  setUp(() {
    deckRepository = FakeDeckRepository();
    flashcardRepository = FakeFlashcardRepository();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      FlashcardApp(
        deckRepository: deckRepository,
        flashcardRepository: flashcardRepository,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Full flow: create deck, add card, study and rate it',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Anglais');
    await tester.enterText(find.byType(TextFormField).at(1), 'Verbes');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Anglais'), findsOneWidget);

    await tester.tap(find.text('Anglais'));
    await tester.pumpAndSettle();
    expect(find.byType(DeckScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Bonjour ?');
    await tester.enterText(find.byType(TextFormField).at(1), 'Hello');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour ?'), findsOneWidget);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();
    expect(find.byType(StudyScreen), findsOneWidget);
    expect(find.text('Bonjour ?'), findsOneWidget);

    await tester.tap(find.text('Voir la réponse'));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    await tester.tap(find.text('Bien'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée !'), findsOneWidget);

    final cards = await flashcardRepository.getAll();
    expect(cards.length, 1);
    expect(cards.first.repetitions, 1);
    expect(cards.first.interval, 1);
  });

  testWidgets('New due card is available in study session', (tester) async {
    final now = DateTime(2026, 1, 1);
    await deckRepository.save(
      Deck(
        id: 'd1',
        title: 'Français',
        description: '',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await flashcardRepository.save(
      Flashcard(
        id: 'c1',
        deckId: 'd1',
        question: 'Bonjour ?',
        answer: 'Hello',
        nextReview: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await pumpApp(tester);
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour ?'), findsOneWidget);
  });
}