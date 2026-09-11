import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../repositories/deck_repository.dart';
import '../repositories/hive_flashcard_repository.dart';
import 'deck_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final DeckRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DeckRepository _repository = widget.repository;

  late Future<List<Deck>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = _repository.getAll();
  }

  void _refresh() {
    setState(() {
      _decksFuture = _repository.getAll();
    });
  }

  Future<void> _createDeck() async {
    final result = await showDialog<Deck>(
      context: context,
      builder: (context) => const _DeckDialog(),
    );
    if (result != null) {
      await _repository.save(result);
      _refresh();
    }
  }

  Future<void> _deleteDeck(Deck deck) async {
    await _repository.delete(deck.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes decks')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDeck,
        tooltip: 'Créer un deck',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Deck>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final decks = snapshot.data ?? [];
          if (decks.isEmpty) {
            return const Center(child: Text('Aucun deck. Créez-en un !'));
          }
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) => _DeckTile(
              deck: decks[index],
              onDelete: () => _deleteDeck(decks[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.deck, required this.onDelete});

  final Deck deck;
  final VoidCallback onDelete;

  Future<void> _openDeck(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeckScreen(
          deck: deck,
          flashcardRepository: HiveFlashcardRepository(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(deck.title.isEmpty ? '?' : deck.title[0].toUpperCase()),
      ),
      title: Text(deck.title),
      subtitle: Text(deck.description),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
        tooltip: 'Supprimer',
      ),
      onTap: () => _openDeck(context),
    );
  }
}

class _DeckDialog extends StatefulWidget {
  const _DeckDialog();

  @override
  State<_DeckDialog> createState() => _DeckDialogState();
}

class _DeckDialogState extends State<_DeckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final deck = Deck(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );
    Navigator.of(context).pop(deck);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau deck'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Requis' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
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
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
