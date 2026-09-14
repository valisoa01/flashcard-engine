import 'dart:math';

import '../models/flashcard.dart';
import '../models/review.dart';

class SpacedRepetitionResult {
  final int repetitions;
  final int interval;
  final double easeFactor;
  final DateTime nextReview;

  const SpacedRepetitionResult({
    required this.repetitions,
    required this.interval,
    required this.easeFactor,
    required this.nextReview,
  });
}

/// Algorithme de répétition espacée inspiré du modèle SM-2, écrit en Dart
/// pur (aucune dépendance à Flutter).
///
/// Règles retenues (T-13) :
/// - Ease Factor initial : 2.5, minimum : 1.3.
/// - Réponse [ReviewQuality.again] : la carte repart de zéro
///   (`repetitions = 0`) et est à revoir le lendemain.
/// - Réponses réussies (hard/good/easy) : `repetitions` augmente de 1 et
///   l'intervalle suit la progression SM-2 : 1, 6/3/12, puis
///   `interval * easeFactor` avec un bonus selon la qualité.
/// - La date de prochaine révision = date de révision + intervalle en jours.
class SpacedRepetitionService {
  static const double initialEaseFactor = 2.5;
  static const double minimumEaseFactor = 1.3;

  int _qualityPoints(ReviewQuality quality) {
    switch (quality) {
      case ReviewQuality.again:
        return 1;
      case ReviewQuality.hard:
        return 3;
      case ReviewQuality.good:
        return 4;
      case ReviewQuality.easy:
        return 5;
    }
  }

  double _updatedEaseFactor(ReviewQuality quality, double easeFactor) {
    final qualityPoints = _qualityPoints(quality);
    final delta =
        0.1 - (5 - qualityPoints) * (0.08 + (5 - qualityPoints) * 0.02);
    return max(easeFactor + delta, minimumEaseFactor).toDouble();
  }

  int _nextInterval(
    ReviewQuality quality,
    int repetitions,
    int previousInterval,
    double easeFactor,
  ) {
    switch (quality) {
      case ReviewQuality.again:
        return 1;
      case ReviewQuality.hard:
        if (repetitions == 1) return 1;
        if (repetitions == 2) return 3;
        return max((previousInterval * easeFactor * 0.5).round(), 1);
      case ReviewQuality.good:
        if (repetitions == 1) return 1;
        if (repetitions == 2) return 6;
        return max((previousInterval * easeFactor).round(), 1);
      case ReviewQuality.easy:
        if (repetitions == 1) return 3;
        if (repetitions == 2) return 12;
        return max((previousInterval * easeFactor * 1.3).round(), 1);
    }
  }

  SpacedRepetitionResult review({
    required ReviewQuality quality,
    required int repetitions,
    required int interval,
    required double easeFactor,
    required DateTime reviewedAt,
  }) {
    final newEaseFactor = _updatedEaseFactor(quality, easeFactor);

    final int newRepetitions;
    if (quality == ReviewQuality.again) {
      newRepetitions = 0;
    } else {
      newRepetitions = repetitions + 1;
    }

    final newInterval =
        _nextInterval(quality, newRepetitions, interval, newEaseFactor);

    final nextReview = reviewedAt.add(Duration(days: newInterval));

    return SpacedRepetitionResult(
      repetitions: newRepetitions,
      interval: newInterval,
      easeFactor: newEaseFactor,
      nextReview: nextReview,
    );
  }

  Flashcard applyQuality({
    required Flashcard flashcard,
    required ReviewQuality quality,
    DateTime? reviewedAt,
  }) {
    final now = reviewedAt ?? DateTime.now();
    final result = review(
      quality: quality,
      repetitions: flashcard.repetitions,
      interval: flashcard.interval,
      easeFactor: flashcard.easeFactor,
      reviewedAt: now,
    );

    return flashcard.copyWith(
      repetitions: result.repetitions,
      interval: result.interval,
      easeFactor: result.easeFactor,
      nextReview: result.nextReview,
      updatedAt: now,
    );
  }

  Review createReview({
    required String id,
    required String flashcardId,
    required ReviewQuality quality,
    required int previousRepetitions,
    required int previousInterval,
    required double previousEaseFactor,
    required DateTime reviewedAt,
  }) {
    final result = review(
      quality: quality,
      repetitions: previousRepetitions,
      interval: previousInterval,
      easeFactor: previousEaseFactor,
      reviewedAt: reviewedAt,
    );

    return Review(
      id: id,
      flashcardId: flashcardId,
      quality: quality,
      reviewedAt: reviewedAt,
      previousInterval: previousInterval,
      newInterval: result.interval,
      previousEaseFactor: previousEaseFactor,
      newEaseFactor: result.easeFactor,
    );
  }
}