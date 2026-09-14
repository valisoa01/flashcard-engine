import 'package:flutter/material.dart';

import '../models/flashcard.dart';

class FlashcardDetailScreen extends StatefulWidget {
  const FlashcardDetailScreen({super.key, required this.card});

  final Flashcard card;

  @override
  State<FlashcardDetailScreen> createState() => _FlashcardDetailScreenState();
}

class _FlashcardDetailScreenState extends State<FlashcardDetailScreen> {
  bool _showAnswer = false;

  void _flip() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0)
                        .animate(animation),
                    child: child,
                  ),
                  child: _showAnswer
                      ? _CardFace(
                          key: const ValueKey('answer'),
                          label: 'Réponse',
                          text: widget.card.answer,
                          color: const Color(0xFF06D6A0),
                        )
                      : _CardFace(
                          key: const ValueKey('question'),
                          label: 'Question',
                          text: widget.card.question,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _flip,
                icon: Icon(
                  _showAnswer ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(_showAnswer ? 'Voir la question' : 'Voir la réponse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.label,
    required this.text,
    required this.color,
    super.key,
  });

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 260),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0.09),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}