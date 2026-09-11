import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/repositories/hive_flashcard_repository.dart';

void main() {
  group('FlashcardRepository', () {
    late HiveFlashcardRepository repository;

    setUp(() async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      repository = HiveFlashcardRepository();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
    });

    test('saves and reads a flashcard', () async {
      final card = Flashcard(
        id: 'card-1',
        deckId: 'deck-1',
        question: '2 + 2 ?',
        answer: '4',
        nextReview: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await repository.save(card);

      final loaded = await repository.getById('card-1');
      expect(loaded, isNotNull);
      expect(loaded!.question, '2 + 2 ?');
      expect(loaded.answer, '4');
    });

    test('filters flashcards by deckId', () async {
      await repository.save(
        Flashcard(
          id: 'c1',
          deckId: 'deck-1',
          question: 'q1',
          answer: 'a1',
          nextReview: DateTime(2026),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );
      await repository.save(
        Flashcard(
          id: 'c2',
          deckId: 'deck-2',
          question: 'q2',
          answer: 'a2',
          nextReview: DateTime(2026),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );

      final cards = await repository.getAll(deckId: 'deck-1');
      expect(cards.length, 1);
      expect(cards.first.id, 'c1');
    });

    test('deletes a flashcard', () async {
      await repository.save(
        Flashcard(
          id: 'c1',
          deckId: 'deck-1',
          question: 'q',
          answer: 'a',
          nextReview: DateTime(2026),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );

      await repository.delete('c1');
      expect(await repository.getById('c1'), isNull);
    });
  });
}
