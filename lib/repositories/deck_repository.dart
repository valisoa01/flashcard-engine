import '../models/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> getAll();

  Future<Deck?> getById(String id);

  Future<void> save(Deck deck);

  Future<void> delete(String id);

  Future<void> clear();
}
