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
                  transitionBuilder: (child, animation) =>
                      RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0)
                        .animate(animation),
                    child: child,
                  ),
                  child: _showAnswer
                      ? _CardFace(
                          key: const ValueKey('answer'),
                          label: 'Réponse',
                          text: widget.card.answer,
                          color: Colors.green,
                        )
                      : _CardFace(
                          key: const ValueKey('question'),
                          label: 'Question',
                          text: widget.card.question,
                          color: Colors.deepPurple,
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
    return Center(
      child: Card(
        color: color.withValues(alpha: 0.1),
        elevation: 4,
        child: Container(
          constraints: const BoxConstraints(minHeight: 260),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}