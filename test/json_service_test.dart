import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:flashcard/models/deck.dart';
import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/services/json_service.dart';

void main() {
  final service = JsonService();
  final now = DateTime(2026, 9, 1);

  Deck deck() => Deck(
        id: 'deck-1',
        title: 'Français',
        description: 'Vocabulaire',
        createdAt: now,
        updatedAt: now,
      );

  Flashcard card() => Flashcard(
        id: 'card-1',
        deckId: 'deck-1',
        question: 'Bonjour ?',
        answer: 'Hello',
        nextReview: now,
        createdAt: now,
        updatedAt: now,
      );

  group('JsonService', () {
    test('exportAll produces a JSON object with decks and flashcards', () {
      final json = service.exportAll(decks: [deck()], flashcards: [card()]);

      final decoded =
          jsonDecode(json) as Map<String, dynamic>;

      expect(decoded['version'], '1');
      expect(decoded['decks'], isA<List<dynamic>>());
      expect(decoded['flashcards'], isA<List<dynamic>>());
      expect((decoded['decks'] as List).length, 1);
      expect((decoded['flashcards'] as List).length, 1);
    });

    test('parse restores decks and flashcards', () {
      final json = service.exportAll(decks: [deck()], flashcards: [card()]);
      final result = service.parse(json);

      expect(result.decks.length, 1);
      expect(result.decks.first.id, 'deck-1');
      expect(result.decks.first.title, 'Français');
      expect(result.flashcards.length, 1);
      expect(result.flashcards.first.question, 'Bonjour ?');
      expect(result.flashcards.first.answer, 'Hello');
      expect(result.flashcards.first.deckId, 'deck-1');
    });

    test('export/parse round-trip keeps flashcard scheduling fields', () {
      final scheduled = card().copyWith(
        repetitions: 3,
        interval: 12,
        easeFactor: 2.7,
        nextReview: now.add(const Duration(days: 12)),
      );

      final json = service.exportAll(decks: [], flashcards: [scheduled]);
      final result = service.parse(json);

      expect(result.flashcards.first.repetitions, 3);
      expect(result.flashcards.first.interval, 12);
      expect(result.flashcards.first.easeFactor, 2.7);
      expect(
        result.flashcards.first.nextReview,
        now.add(const Duration(days: 12)),
      );
    });

    test('parse throws FormatException on empty input', () {
      expect(
        () => service.parse(''),
        throwsA(isA<FormatException>()),
      );
    });

    test('parse throws FormatException on invalid JSON', () {
      expect(
        () => service.parse('pas du json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('parse accepts missing optional sections', () {
      final result = service.parse('{"version":"1"}');

      expect(result.decks, isEmpty);
      expect(result.flashcards, isEmpty);
    });
  });
}