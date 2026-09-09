import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/app.dart';
import 'package:flashcard/models/deck.dart';

import 'fakes/fake_deck_repository.dart';

void main() {
  late FakeDeckRepository repository;

  setUp(() {
    repository = FakeDeckRepository();
  });

  testWidgets('Home screen shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(FlashcardApp(deckRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Mes decks'), findsOneWidget);
    expect(find.text('Aucun deck. Créez-en un !'), findsOneWidget);
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

    await tester.pumpWidget(FlashcardApp(deckRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Vocabulaire'), findsOneWidget);
  });

  testWidgets('Creates a deck via dialog', (WidgetTester tester) async {
    await tester.pumpWidget(FlashcardApp(deckRepository: repository));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Anglais');
    await tester.enterText(find.byType(TextFormField).at(1), 'Verbes');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Anglais'), findsOneWidget);
    expect(find.text('Verbes'), findsOneWidget);
  });
}
