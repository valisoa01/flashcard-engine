import 'package:flashcard/models/deck.dart';
import 'package:flashcard/repositories/deck_repository.dart';

class FakeDeckRepository implements DeckRepository {
  final List<Deck> _decks = [];

  @override
  Future<List<Deck>> getAll() async => List.unmodifiable(_decks);

  @override
  Future<Deck?> getById(String id) async {
    for (final deck in _decks) {
      if (deck.id == id) return deck;
    }
    return null;
  }

  @override
  Future<void> save(Deck deck) async {
    _decks.removeWhere((d) => d.id == deck.id);
    _decks.add(deck);
  }

  @override
  Future<void> delete(String id) async {
    _decks.removeWhere((d) => d.id == id);
  }

  @override
  Future<void> clear() async => _decks.clear();
}
