import 'package:flashcard/models/flashcard.dart';
import 'package:flashcard/repositories/flashcard_repository.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  final List<Flashcard> _cards = [];

  @override
  Future<List<Flashcard>> getAll({String? deckId}) async {
    if (deckId != null) {
      return List.unmodifiable(
        _cards.where((card) => card.deckId == deckId),
      );
    }
    return List.unmodifiable(_cards);
  }

  @override
  Future<Flashcard?> getById(String id) async {
    for (final card in _cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  @override
  Future<void> save(Flashcard card) async {
    _cards.removeWhere((c) => c.id == card.id);
    _cards.add(card);
  }

  @override
  Future<void> delete(String id) async {
    _cards.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> clear() async => _cards.clear();
}