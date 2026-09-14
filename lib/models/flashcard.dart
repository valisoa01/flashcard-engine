class Flashcard {
  final String id;
  final String deckId;

  final String question;
  final String answer;

  final int repetitions;

  final int interval;

  final double easeFactor;

  final DateTime nextReview;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.repetitions = 0,
    this.interval = 0,
    this.easeFactor = 2.5,
    required this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDue {
    return !nextReview.isAfter(DateTime.now());
  }

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? question,
    String? answer,
    int? repetitions,
    int? interval,
    double? easeFactor,
    DateTime? nextReview,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      repetitions: repetitions ?? this.repetitions,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'question': question,
      'answer': answer,
      'repetitions': repetitions,
      'interval': interval,
      'easeFactor': easeFactor,
      'nextReview': nextReview.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      repetitions: json['repetitions'] as int? ?? 0,
      interval: json['interval'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      nextReview: DateTime.parse(json['nextReview'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Flashcard('
        'id: $id, '
        'deckId: $deckId, '
        'question: $question, '
        'answer: $answer, '
        'repetitions: $repetitions, '
        'interval: $interval, '
        'easeFactor: $easeFactor, '
        'nextReview: $nextReview'
        ')';
  }
}
