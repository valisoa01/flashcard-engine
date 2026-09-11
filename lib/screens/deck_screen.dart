import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';
import 'flashcard_detail_screen.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({
    super.key,
    required this.deck,
    required this.flashcardRepository,
  });

  final Deck deck;
  final FlashcardRepository flashcardRepository;

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  late final FlashcardRepository _repository = widget.flashcardRepository;

  late Future<List<Flashcard>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _cardsFuture = _repository.getAll(deckId: widget.deck.id);
  }

  void _refresh() {
    setState(() {
      _cardsFuture = _repository.getAll(deckId: widget.deck.id);
    });
  }

  Future<void> _openFlashcardForm({Flashcard? card}) async {
    final result = await showDialog<Flashcard>(
      context: context,
      builder: (context) => _FlashcardDialog(deckId: widget.deck.id, card: card),
    );
    if (result != null) {
      await _repository.save(result);
      _refresh();
    }
  }

  Future<void> _deleteFlashcard(Flashcard card) async {
    await _repository.delete(card.id);
    _refresh();
  }

  Future<void> _openDetail(Flashcard card) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FlashcardDetailScreen(card: card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFlashcardForm,
        tooltip: 'Créer une carte',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final cards = snapshot.data ?? [];
          return ListView(
            children: [
              _DeckHeader(deck: widget.deck, cardCount: cards.length),
              if (cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Aucune carte. Créez-en une !')),
                )
              else
                for (final card in cards)
                  _FlashcardTile(
                    card: card,
                    onOpen: () => _openDetail(card),
                    onEdit: () => _openFlashcardForm(card: card),
                    onDelete: () => _deleteFlashcard(card),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({required this.deck, required this.cardCount});

  final Deck deck;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(deck.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '$cardCount carte${cardCount > 1 ? 's' : ''}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardTile extends StatelessWidget {
  const _FlashcardTile({
    required this.card,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Flashcard card;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.style_outlined)),
        title: Text(
          card.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onOpen,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardDialog extends StatefulWidget {
  const _FlashcardDialog({required this.deckId, this.card});

  final String deckId;
  final Flashcard? card;

  @override
  State<_FlashcardDialog> createState() => _FlashcardDialogState();
}

class _FlashcardDialogState extends State<_FlashcardDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.card?.question);
    _answerController = TextEditingController(text: widget.card?.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final card = widget.card?.copyWith(
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          updatedAt: now,
        ) ??
        Flashcard(
          id: now.microsecondsSinceEpoch.toString(),
          deckId: widget.deckId,
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          nextReview: now,
          createdAt: now,
          updatedAt: now,
        );
    Navigator.of(context).pop(card);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier la carte' : 'Nouvelle carte'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Requis' : null,
            ),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Réponse'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Requis' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}