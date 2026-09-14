import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/models/review.dart';
import 'package:flashcard/services/spaced_repetition_service.dart';
import 'package:flutter_test/flutter_test.dart';

Flashcard makeCard({
  int repetitions = 0,
  int interval = 0,
  double easeFactor = 2.5,
}) {
  final now = DateTime(2026, 9, 14);
  return Flashcard(
    id: 'card-1',
    deckId: 'deck-1',
    question: 'Question',
    answer: 'Answer',
    repetitions: repetitions,
    interval: interval,
    easeFactor: easeFactor,
    nextReview: now,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final service = SpacedRepetitionService();
  final reviewedAt = DateTime(2026, 9, 14, 10);

  group('SpacedRepetitionService', () {
    test('review again resets repetitions to 0 and returns interval 1 day',
        () {
      final result = service.review(
        quality: ReviewQuality.again,
        repetitions: 5,
        interval: 60,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 0);
      expect(result.interval, 1);
      expect(result.nextReview, reviewedAt.add(const Duration(days: 1)));
    });

    test('review again decreases ease factor but never below minimum', () {
      final result = service.review(
        quality: ReviewQuality.again,
        repetitions: 5,
        interval: 60,
        easeFactor: 1.4,
        reviewedAt: reviewedAt,
      );

      expect(result.easeFactor, SpacedRepetitionService.minimumEaseFactor);
    });

    test('good on a new card gives interval 1 day', () {
      final result = service.review(
        quality: ReviewQuality.good,
        repetitions: 0,
        interval: 0,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 1);
    });

    test('hard on a new card gives interval 1 day', () {
      final result = service.review(
        quality: ReviewQuality.hard,
        repetitions: 0,
        interval: 0,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 1);
    });

    test('easy on a new card gives interval 3 days and raises ease factor',
        () {
      final result = service.review(
        quality: ReviewQuality.easy,
        repetitions: 0,
        interval: 0,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 3);
      expect(result.easeFactor, greaterThan(2.5));
    });

    test('good second review gives interval 6 days', () {
      final result = service.review(
        quality: ReviewQuality.good,
        repetitions: 1,
        interval: 1,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 2);
      expect(result.interval, 6);
    });

    test('good third review grows interval with ease factor', () {
      final result = service.review(
        quality: ReviewQuality.good,
        repetitions: 2,
        interval: 6,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.repetitions, 3);
      expect(result.interval, (6 * 2.5).round());
    });

    test('nextReview is reviewedAt plus interval days', () {
      final result = service.review(
        quality: ReviewQuality.good,
        repetitions: 1,
        interval: 1,
        easeFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(result.nextReview, reviewedAt.add(const Duration(days: 6)));
    });

    test('applyQuality updates the flashcard fields and updatedAt', () {
      final card = makeCard();

      final updated = service.applyQuality(
        flashcard: card,
        quality: ReviewQuality.good,
        reviewedAt: reviewedAt,
      );

      expect(updated.repetitions, 1);
      expect(updated.interval, 1);
      expect(updated.nextReview, reviewedAt.add(const Duration(days: 1)));
      expect(updated.updatedAt, reviewedAt);
      expect(updated.question, card.question);
      expect(updated.deckId, card.deckId);
    });

    test('applyQuality resets card on again answer', () {
      final card = makeCard(repetitions: 8, interval: 100, easeFactor: 2.6);

      final updated = service.applyQuality(
        flashcard: card,
        quality: ReviewQuality.again,
        reviewedAt: reviewedAt,
      );

      expect(updated.repetitions, 0);
      expect(updated.interval, 1);
      expect(updated.easeFactor, lessThan(2.6));
    });

    test('createReview records previous and new state', () {
      final review = service.createReview(
        id: 'review-1',
        flashcardId: 'card-1',
        quality: ReviewQuality.good,
        previousRepetitions: 1,
        previousInterval: 1,
        previousEaseFactor: 2.5,
        reviewedAt: reviewedAt,
      );

      expect(review.previousInterval, 1);
      expect(review.newInterval, 6);
      expect(review.previousEaseFactor, 2.5);
      expect(review.newEaseFactor, closeTo(2.5, 0.001));
      expect(review.reviewedAt, reviewedAt);
    });
  });
}