import 'package:hive/hive.dart';

import '../models/flashcard.dart';

class FlashcardRepository {
  static const _boxName = 'flashcards';

  Box<dynamic>? _box;

  Future<Box<dynamic>> get _boxInstance async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    return _box!;
  }

  Future<List<Flashcard>> getAll({String? deckId}) async {
    final box = await _boxInstance;
    final cards = box.values
        .map((value) => Flashcard.fromJson(Map<String, dynamic>.from(value)))
        .toList();
    if (deckId != null) {
      return cards.where((card) => card.deckId == deckId).toList();
    }
    return cards;
  }

  Future<Flashcard?> getById(String id) async {
    final box = await _boxInstance;
    final value = box.get(id);
    if (value == null) return null;
    return Flashcard.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> save(Flashcard card) async {
    final box = await _boxInstance;
    await box.put(card.id, card.toJson());
  }

  Future<void> delete(String id) async {
    final box = await _boxInstance;
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _boxInstance;
    await box.clear();
  }
}
