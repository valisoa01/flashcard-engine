import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/review.dart';
import '../repositories/flashcard_repository.dart';
import '../services/spaced_repetition_service.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.deck,
    required this.flashcardRepository,
  });

  final Deck deck;
  final FlashcardRepository flashcardRepository;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final SpacedRepetitionService _spacedRepetition = SpacedRepetitionService();

  late final FlashcardRepository _repository = widget.flashcardRepository;
  late Future<List<Flashcard>> _loadFuture;

  List<Flashcard> _queue = [];
  int _index = 0;
  bool _showAnswer = false;
  bool _finished = false;
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadDueCards();
  }

  Future<List<Flashcard>> _loadDueCards() async {
    final cards = await _repository.getAll(deckId: widget.deck.id);
    return cards.where((card) => card.isDue).toList();
  }

  Flashcard get _current => _queue[_index];

  void _reveal() {
    setState(() {
      _showAnswer = true;
    });
  }

  Future<void> _rate(ReviewQuality quality) async {
    final current = _current;
    final updated = _spacedRepetition.applyQuality(
      flashcard: current,
      quality: quality,
    );
    await _repository.save(updated);

    switch (quality) {
      case ReviewQuality.again:
        _againCount++;
      case ReviewQuality.hard:
        _hardCount++;
      case ReviewQuality.good:
        _goodCount++;
      case ReviewQuality.easy:
        _easyCount++;
    }

    setState(() {
      if (_index + 1 >= _queue.length) {
        _finished = true;
      } else {
        _index++;
        _showAnswer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réviser : ${widget.deck.title}')),
      body: FutureBuilder<List<Flashcard>>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          _queue = snapshot.data ?? [];
          if (_queue.isEmpty) {
            return const Center(
              child: Text('Aucune carte à réviser pour le moment.'),
            );
          }
          if (_finished) {
            return _StudySummary(
              again: _againCount,
              hard: _hardCount,
              good: _goodCount,
              easy: _easyCount,
            );
          }
          return _StudySession(
            card: _current,
            index: _index,
            total: _queue.length,
            showAnswer: _showAnswer,
            onReveal: _reveal,
            onRate: _rate,
          );
        },
      ),
    );
  }
}

class _StudySession extends StatelessWidget {
  const _StudySession({
    required this.card,
    required this.index,
    required this.total,
    required this.showAnswer,
    required this.onReveal,
    required this.onRate,
  });

  final Flashcard card;
  final int index;
  final int total;
  final bool showAnswer;
  final VoidCallback onReveal;
  final ValueChanged<ReviewQuality> onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Carte ${index + 1} / $total',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(animation),
                child: child,
              ),
              child: Card(
                key: ValueKey(showAnswer ? 'answer' : 'question'),
                color: (showAnswer ? Colors.green : Colors.deepPurple)
                    .withValues(alpha: 0.1),
                elevation: 4,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 260),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      showAnswer ? card.answer : card.question,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!showAnswer)
            FilledButton.icon(
              onPressed: onReveal,
              icon: const Icon(Icons.visibility),
              label: const Text('Voir la réponse'),
            )
          else
            Row(
              children: [
                _RateButton(
                  label: 'Encore',
                  color: Colors.red,
                  onPressed: () => onRate(ReviewQuality.again),
                ),
                const SizedBox(width: 8),
                _RateButton(
                  label: 'Difficile',
                  color: Colors.orange,
                  onPressed: () => onRate(ReviewQuality.hard),
                ),
                const SizedBox(width: 8),
                _RateButton(
                  label: 'Bien',
                  color: Colors.green,
                  onPressed: () => onRate(ReviewQuality.good),
                ),
                const SizedBox(width: 8),
                _RateButton(
                  label: 'Facile',
                  color: Colors.blue,
                  onPressed: () => onRate(ReviewQuality.easy),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }
}

class _StudySummary extends StatelessWidget {
  const _StudySummary({
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  final int again;
  final int hard;
  final int good;
  final int easy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 56),
            const SizedBox(height: 16),
            Text('Session terminée !', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text(
              'Encore : $again   Difficile : $hard\n'
              'Bien : $good   Facile : $easy',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}