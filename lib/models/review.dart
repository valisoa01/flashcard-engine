enum ReviewQuality { again, hard, good, easy }

class Review {
  final String id;
  final String flashcardId;

  final ReviewQuality quality;
  final DateTime reviewedAt;

  final int previousInterval;

  final int newInterval;

  final double previousEaseFactor;

  final double newEaseFactor;

  const Review({
    required this.id,
    required this.flashcardId,
    required this.quality,
    required this.reviewedAt,
    required this.previousInterval,
    required this.newInterval,
    required this.previousEaseFactor,
    required this.newEaseFactor,
  });

  Review copyWith({
    String? id,
    String? flashcardId,
    ReviewQuality? quality,
    DateTime? reviewedAt,
    int? previousInterval,
    int? newInterval,
    double? previousEaseFactor,
    double? newEaseFactor,
  }) {
    return Review(
      id: id ?? this.id,
      flashcardId: flashcardId ?? this.flashcardId,
      quality: quality ?? this.quality,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      previousInterval: previousInterval ?? this.previousInterval,
      newInterval: newInterval ?? this.newInterval,
      previousEaseFactor: previousEaseFactor ?? this.previousEaseFactor,
      newEaseFactor: newEaseFactor ?? this.newEaseFactor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flashcardId': flashcardId,
      'quality': quality.name,
      'reviewedAt': reviewedAt.toIso8601String(),
      'previousInterval': previousInterval,
      'newInterval': newInterval,
      'previousEaseFactor': previousEaseFactor,
      'newEaseFactor': newEaseFactor,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      flashcardId: json['flashcardId'] as String,
      quality: ReviewQuality.values.firstWhere(
        (value) => value.name == json['quality'],
        orElse: () => ReviewQuality.good,
      ),
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      previousInterval: json['previousInterval'] as int? ?? 0,
      newInterval: json['newInterval'] as int? ?? 0,
      previousEaseFactor:
          (json['previousEaseFactor'] as num?)?.toDouble() ?? 2.5,
      newEaseFactor: (json['newEaseFactor'] as num?)?.toDouble() ?? 2.5,
    );
  }

  @override
  String toString() {
    return 'Review('
        'id: $id, '
        'flashcardId: $flashcardId, '
        'quality: $quality, '
        'reviewedAt: $reviewedAt, '
        'previousInterval: $previousInterval, '
        'newInterval: $newInterval, '
        'previousEaseFactor: $previousEaseFactor, '
        'newEaseFactor: $newEaseFactor'
        ')';
  }
}
