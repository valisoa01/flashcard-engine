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
          final Widget content;
          if (_queue.isEmpty) {
            content = _EmptyState();
          } else if (_finished) {
            content = _StudySummary(
              again: _againCount,
              hard: _hardCount,
              good: _goodCount,
              easy: _easyCount,
            );
          } else {
            content = _StudySession(
              card: _current,
              index: _index,
              total: _queue.length,
              showAnswer: _showAnswer,
              onReveal: _reveal,
              onRate: _rate,
            );
          }
          return CustomScrollView(
            slivers: [
              _StudyHeader(deck: widget.deck, total: _queue.length),
              SliverFillRemaining(
                hasScrollBody: false,
                child: content,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudyHeader extends StatelessWidget {
  const _StudyHeader({required this.deck, required this.total});

  final Deck deck;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 140,
      backgroundColor: colorScheme.primary,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Icon(
                  Icons.school_outlined,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Séance de révision',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deck.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$total carte${total > 1 ? 's' : ''} à réviser',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune carte à réviser pour le moment.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Reviens plus tard ou ajoute de nouvelles cartes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
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
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (index + 1) / total,
              minHeight: 6,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Carte ${index + 1} / $total',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.5, end: 1.0)
                    .animate(animation),
                child: child,
              ),
              child: Card(
                key: ValueKey(showAnswer ? 'answer' : 'question'),
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 240),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: showAnswer
                          ? [
                              const Color(0xFF06D6A0).withValues(alpha: 0.16),
                              const Color(0xFF5CE8BE).withValues(alpha: 0.16),
                            ]
                          : [
                              colorScheme.primary.withValues(alpha: 0.14),
                              colorScheme.tertiary.withValues(alpha: 0.14),
                            ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (showAnswer
                                    ? const Color(0xFF06D6A0)
                                    : colorScheme.primary)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            showAnswer ? 'RÉPONSE' : 'QUESTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: showAnswer
                                  ? const Color(0xFF06D6A0)
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          showAnswer ? card.answer : card.question,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
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
        child: FittedBox(child: Text(label)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Session terminée !',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Voici le bilan de ta séance de révision.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SummaryRow(
                    icon: Icons.refresh,
                    label: 'Encore',
                    count: again,
                    color: const Color(0xFFEF476F),
                  ),
                  const Divider(height: 1),
                  _SummaryRow(
                    icon: Icons.trending_up,
                    label: 'Difficile',
                    count: hard,
                    color: const Color(0xFFFFA62B),
                  ),
                  const Divider(height: 1),
                  _SummaryRow(
                    icon: Icons.thumb_up_alt_outlined,
                    label: 'Bien',
                    count: good,
                    color: const Color(0xFF06D6A0),
                  ),
                  const Divider(height: 1),
                  _SummaryRow(
                    icon: Icons.bolt_outlined,
                    label: 'Facile',
                    count: easy,
                    color: const Color(0xFF3A86FF),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.done_all),
            label: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}