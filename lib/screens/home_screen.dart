import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../services/firestore_sync_service.dart';
import '../services/json_service.dart';
import 'deck_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.flashcardRepository,
  });

  final DeckRepository repository;
  final FlashcardRepository flashcardRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JsonService _jsonService = JsonService();

  late final DeckRepository _repository = widget.repository;
  late final FlashcardRepository _flashcardRepository =
      widget.flashcardRepository;

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

  Future<List<Flashcard>> _allFlashcards() =>
      _flashcardRepository.getAll();

  Future<void> _exportJson() async {
    final decks = await _repository.getAll();
    final cards = await _allFlashcards();
    final json = _jsonService.exportAll(decks: decks, flashcards: cards);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => JsonExportDialog(json: json),
    );
  }

  Future<void> _importJson() async {
    final imported = await showDialog<JsonExport>(
      context: context,
      builder: (context) => const JsonImportDialog(),
    );
    if (imported == null) return;

    for (final deck in imported.decks) {
      await _repository.save(deck);
    }
    for (final card in imported.flashcards) {
      await _flashcardRepository.save(card);
    }
    _refresh();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Import réussi : ${imported.decks.length} deck(s), '
          '${imported.flashcards.length} carte(s).',
        ),
      ),
    );
  }

  Future<void> _openSyncDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => FirestoreSyncDialog(
        service: FirestoreSyncService(
          deckRepository: _repository,
          flashcardRepository: _flashcardRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Synchronisation Firestore',
            onPressed: _openSyncDialog,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'Importer JSON',
            onPressed: _importJson,
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exporter JSON',
            onPressed: _exportJson,
          ),
        ],
      ),
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
              flashcardRepository: widget.flashcardRepository,
              onDelete: () => _deleteDeck(decks[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.deck,
    required this.flashcardRepository,
    required this.onDelete,
  });

  final Deck deck;
  final FlashcardRepository flashcardRepository;
  final VoidCallback onDelete;

  Future<void> _openDeck(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeckScreen(
          deck: deck,
          flashcardRepository: flashcardRepository,
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

class JsonExportDialog extends StatelessWidget {
  const JsonExportDialog({super.key, required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: json);
    return AlertDialog(
      title: const Text('Export JSON'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Copiez le contenu ci-dessous pour sauvegarder vos données.'),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            width: double.maxFinite,
            child: TextField(
              controller: textController,
              maxLines: null,
              expands: true,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        FilledButton(
          onPressed: () {
            // On mobile/desktop the copy won't automatically work,
            // but the text is fully selectable.
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class JsonImportDialog extends StatefulWidget {
  const JsonImportDialog({super.key});

  @override
  State<JsonImportDialog> createState() => _JsonImportDialogState();
}

class _JsonImportDialogState extends State<JsonImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text;
    try {
      final data = JsonService().parse(raw);
      Navigator.of(context).pop(data);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importer JSON'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Collez le JSON exporté puis validez.'),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            width: double.maxFinite,
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                errorText: _error,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Importer'),
        ),
      ],
    );
  }
}

class FirestoreSyncDialog extends StatefulWidget {
  const FirestoreSyncDialog({super.key, required this.service});

  final FirestoreSyncService service;

  @override
  State<FirestoreSyncDialog> createState() => _FirestoreSyncDialogState();
}

class _FirestoreSyncDialogState extends State<FirestoreSyncDialog> {
  bool? _available;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await widget.service.isAvailable;
    if (!mounted) return;
    setState(() {
      _available = available;
    });
  }

  Future<void> _run(Future<SyncResult> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    try {
      final result = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Synchronisation Firestore'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_available == null)
            const Center(child: CircularProgressIndicator())
          else if (!_available!)
            const Text(
              'Firebase n\u{2019}est pas configuré sur cet appareil. '
              'La synchronisation est désactivée.',
            )
          else ...[
            const Text(
              'Poussez vos données vers Firestore ou récupérez celles '
              'qui y sont stockées.',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.tonalIcon(
                  onPressed:
                      _busy ? null : () => _run(widget.service.pushAll),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Pousser'),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      _busy ? null : () => _run(widget.service.pullAll),
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Récupérer'),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
