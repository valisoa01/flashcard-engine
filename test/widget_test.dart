import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/app.dart';
import 'package:flashcard/models/deck.dart';

import 'fakes/fake_deck_repository.dart';
import 'fakes/fake_flashcard_repository.dart';

void main() {
  late FakeDeckRepository repository;
  late FakeFlashcardRepository flashcardRepository;

  setUp(() {
    repository = FakeDeckRepository();
    flashcardRepository = FakeFlashcardRepository();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      FlashcardApp(
        deckRepository: repository,
        flashcardRepository: flashcardRepository,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home screen shows empty state', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('FlashCard Engine'), findsOneWidget);
    expect(find.text('Aucun deck pour le moment'), findsOneWidget);
  });

  testWidgets('Home screen lists decks', (WidgetTester tester) async {
    final now = DateTime(2026, 1, 1);
    await repository.save(
      Deck(
        id: 'd1',
        title: 'Français',
        description: 'Vocabulaire',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await pumpApp(tester);

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Vocabulaire'), findsOneWidget);
  });

  testWidgets('Creates a deck via dialog', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.byIcon(Icons.add), findsNWidgets(2));
    await tester.tap(find.text('Nouveau deck'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Anglais');
    await tester.enterText(find.byType(TextFormField).at(1), 'Verbes');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Anglais'), findsOneWidget);
    expect(find.text('Verbes'), findsOneWidget);
  });
}
