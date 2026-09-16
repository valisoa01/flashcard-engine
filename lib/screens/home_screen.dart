import 'package:flutter/material.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';
import '../services/firestore_sync_service.dart';
import '../services/json_service.dart';
import 'deck_screen.dart';
import 'package:flutter/services.dart';
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

class _HomeData {
  const _HomeData({required this.decks, required this.cardsByDeck});

  final List<Deck> decks;
  final Map<String, List<Flashcard>> cardsByDeck;

  int get totalCards =>
      cardsByDeck.values.fold(0, (sum, cards) => sum + cards.length);

  int get totalDue => cardsByDeck.values.fold(
        0,
        (sum, cards) => sum + cards.where((c) => c.isDue).length,
      );
}

class _HomeScreenState extends State<HomeScreen> {
  final JsonService _jsonService = JsonService();

  late final DeckRepository _repository = widget.repository;
  late final FlashcardRepository _flashcardRepository =
      widget.flashcardRepository;

  Future<_HomeData> _dataFuture = Future.value(
    const _HomeData(decks: [], cardsByDeck: {}),
  );

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_HomeData> _loadData() async {
    final decks = await _repository.getAll();
    final cards = await _flashcardRepository.getAll();
    final cardsByDeck = <String, List<Flashcard>>{};
    for (final card in cards) {
      cardsByDeck.putIfAbsent(card.deckId, () => []).add(card);
    }
    return _HomeData(decks: decks, cardsByDeck: cardsByDeck);
  }

  Future<void> _refresh() async {
    final data = _loadData();
    setState(() {
      _dataFuture = data;
    });
    await data;
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

  Future<void> _editDeck(Deck deck) async {
    final result = await showDialog<Deck>(
      context: context,
      builder: (context) => _DeckDialog(deck: deck),
    );
    if (result != null) {
      await _repository.save(result);
      _refresh();
    }
  }

  Future<void> _confirmDeleteDeck(Deck deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce deck ?'),
        content: Text(
          'Le deck « ${deck.title} » et toutes ses cartes seront '
          'définitivement supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final cards = await _flashcardRepository.getAll(deckId: deck.id);
      for (final card in cards) {
        await _flashcardRepository.delete(card.id);
      }
      await _repository.delete(deck.id);
      _refresh();
    }
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createDeck,
        tooltip: 'Créer un deck',
        icon: const Icon(Icons.add),
        label: const Text('Nouveau deck'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState != ConnectionState.done;
            final data = snapshot.data;
            final decks = data?.decks ?? [];

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _HomeHeader(
                  deckCount: decks.length,
                  cardCount: data?.totalCards ?? 0,
                  dueCount: data?.totalDue ?? 0,
                  onSync: _openSyncDialog,
                  onImport: _importJson,
                  onExport: _exportJson,
                ),
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('Erreur : ${snapshot.error}'),
                    ),
                  )
                else if (decks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(onCreate: _createDeck),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = (constraints.crossAxisExtent / 240)
                            .floor()
                            .clamp(1, 4)
                            .toInt();
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.35,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final deck = decks[index];
                              final cards =
                                  data!.cardsByDeck[deck.id] ?? const [];
                              return _DeckTile(
                                deck: deck,
                                cardCount: cards.length,
                                dueCount:
                                    cards.where((c) => c.isDue).length,
                                flashcardRepository:
                                    widget.flashcardRepository,
                                onEdit: () => _editDeck(deck),
                                onDelete: () => _confirmDeleteDeck(deck),
                                onChanged: _refresh,
                              );
                            },
                            childCount: decks.length,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.deckCount,
    required this.cardCount,
    required this.dueCount,
    required this.onSync,
    required this.onImport,
    required this.onExport,
  });

  final int deckCount;
  final int cardCount;
  final int dueCount;
  final VoidCallback onSync;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 210,
      backgroundColor: colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.cloud_sync_outlined),
          tooltip: 'Synchronisation Firestore',
          onPressed: onSync,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Plus d\u2019options',
          onSelected: (value) {
            if (value == 'import') onImport();
            if (value == 'export') onExport();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'import',
              child: ListTile(
                leading: Icon(Icons.upload_file_outlined),
                title: Text('Importer JSON'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download_outlined),
                title: Text('Exporter JSON'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.style_outlined,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'FlashCard Engine',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apprends un peu, tous les jours.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.style_outlined,
                            label: 'decks',
                            value: '$deckCount',
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.credit_card_outlined,
                            label: 'cartes',
                            value: '$cardCount',
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.local_fire_department_outlined,
                            label: 'à réviser',
                            value: '$dueCount',
                            highlight: dueCount > 0,
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.white.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlight ? const Color(0xFFEF476F) : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              color: highlight ? const Color(0xFFEF476F) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
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
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun deck pour le moment',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crée ton premier deck pour commencer à apprendre '
              'avec la répétition espacée.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier deck'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.deck,
    required this.cardCount,
    required this.dueCount,
    required this.flashcardRepository,
    required this.onEdit,
    required this.onDelete,
    required this.onChanged,
  });

  final Deck deck;
  final int cardCount;
  final int dueCount;
  final FlashcardRepository flashcardRepository;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  Future<void> _openDeck(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DeckScreen(
          deck: deck,
          flashcardRepository: flashcardRepository,
        ),
      ),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForDeck(deck.id);
    final initial = deck.title.isEmpty ? '?' : deck.title[0].toUpperCase();

    return Card(
      child: InkWell(
        onTap: () => _openDeck(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 14,
                    bottom: -18,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: colors.first,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: Colors.white,
                          tooltip: 'Modifier',
                          visualDensity: VisualDensity.compact,
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.white,
                          tooltip: 'Supprimer',
                          visualDensity: VisualDensity.compact,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 24, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    if (deck.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        deck.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _CountChip(
                          icon: Icons.credit_card_outlined,
                          label: '$cardCount carte${cardCount > 1 ? 's' : ''}',
                          color: colors.first,
                        ),
                        if (dueCount > 0)
                          _CountChip(
                            icon: Icons.local_fire_department_outlined,
                            label: '$dueCount à réviser',
                            color: const Color(0xFFEF476F),
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
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckDialog extends StatefulWidget {
  const _DeckDialog({this.deck});

  final Deck? deck;

  @override
  State<_DeckDialog> createState() => _DeckDialogState();
}

class _DeckDialogState extends State<_DeckDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.deck?.title);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.deck?.description);

  bool get _isEditing => widget.deck != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final deck = widget.deck?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          updatedAt: now,
        ) ??
        Deck(
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
      title: Text(_isEditing ? 'Modifier le deck' : 'Nouveau deck'),
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
          child: Text(_isEditing ? 'Enregistrer' : 'Créer'),
        ),
      ],
    );
  }
}

class JsonExportDialog extends StatefulWidget {
  const JsonExportDialog({super.key, required this.json});

  final String json;

  @override
  State<JsonExportDialog> createState() => _JsonExportDialogState();
}

class _JsonExportDialogState extends State<JsonExportDialog> {
  late final TextEditingController _textController =
      TextEditingController(text: widget.json);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.json));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copié dans le presse-papiers.')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _textController,
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
          onPressed: _copyToClipboard,
          child: const Text('Copier'),
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
