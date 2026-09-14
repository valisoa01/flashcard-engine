import '../models/flashcard.dart';

abstract class FlashcardRepository {
  Future<List<Flashcard>> getAll({String? deckId});

  Future<Flashcard?> getById(String id);

  Future<void> save(Flashcard card);

  Future<void> delete(String id);

  Future<void> clear();
}
