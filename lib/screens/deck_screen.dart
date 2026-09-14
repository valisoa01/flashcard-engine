import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';
import 'flashcard_detail_screen.dart';
import 'study_screen.dart';

const List<List<Color>> _deckPalette = [
  [Color(0xFF6C63FF), Color(0xFF9D8CFF)],
  [Color(0xFF0EA5E9), Color(0xFF67D3F7)],
  [Color(0xFFFF6B6B), Color(0xFFFF9E7D)],
  [Color(0xFFFFA62B), Color(0xFFFFCB6B)],
  [Color(0xFF06D6A0), Color(0xFF5CE8BE)],
  [Color(0xFFEF476F), Color(0xFFFF8FAE)],
  [Color(0xFF3A86FF), Color(0xFF7FB1FF)],
];

List<Color> _colorsForDeck(String id) {
  final index = id.hashCode.abs() % _deckPalette.length;
  return _deckPalette[index];
}

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
          return CustomScrollView(
            slivers: [
              _DeckHeader(
                deck: widget.deck,
                cardCount: cards.length,
                dueCount: cards.where((c) => c.isDue).length,
                onStudy: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => StudyScreen(
                      deck: widget.deck,
                      flashcardRepository: widget.flashcardRepository,
                    ),
                  ),
                ),
              ),
              if (cards.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onCreate: _openFlashcardForm),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _FlashcardTile(
                        card: cards[index],
                        onOpen: () => _openDetail(cards[index]),
                        onEdit: () => _openFlashcardForm(card: cards[index]),
                        onDelete: () => _deleteFlashcard(cards[index]),
                      ),
                      childCount: cards.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.deck,
    required this.cardCount,
    required this.dueCount,
    required this.onStudy,
  });

  final Deck deck;
  final int cardCount;
  final int dueCount;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    final accent = _colorsForDeck(deck.id);
    final initial = deck.title.isEmpty ? '?' : deck.title[0].toUpperCase();

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 200,
      backgroundColor: accent.first,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: accent,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.collections_bookmark_outlined,
                  size: 170,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: accent.first,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              deck.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (deck.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          deck.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _HeaderPill(
                            icon: Icons.credit_card_outlined,
                            label: '$cardCount carte${cardCount > 1 ? 's' : ''}',
                          ),
                          const SizedBox(width: 10),
                          _HeaderPill(
                            icon: Icons.local_fire_department_outlined,
                            label: '$dueCount à réviser',
                            highlighted: dueCount > 0,
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: onStudy,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: accent.first,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.school_outlined, size: 18),
                            label: const Text('Réviser'),
                          ),
                        ],
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

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.white.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlighted ? const Color(0xFFEF476F) : Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: highlighted ? const Color(0xFFEF476F) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

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
                Icons.style_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune carte. Créez-en une !',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoute tes premières cartes pour commencer '
              'la répétition espacée.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Créer une carte'),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final accent = _colorsForDeck(card.deckId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: accent,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.style_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (card.answer.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        card.answer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (card.isDue) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF476F).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 12,
                              color: Color(0xFFEF476F),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'à réviser',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEF476F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    tooltip: 'Modifier',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
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