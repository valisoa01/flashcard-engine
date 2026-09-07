import 'package:hive/hive.dart';

import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class HiveFlashcardRepository implements FlashcardRepository {
  static const _boxName = 'flashcards';

  Box<dynamic>? _box;

  Future<Box<dynamic>> get _boxInstance async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    return _box!;
  }

  @override
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

  @override
  Future<Flashcard?> getById(String id) async {
    final box = await _boxInstance;
    final value = box.get(id);
    if (value == null) return null;
    return Flashcard.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<void> save(Flashcard card) async {
    final box = await _boxInstance;
    await box.put(card.id, card.toJson());
  }

  @override
  Future<void> delete(String id) async {
    final box = await _boxInstance;
    await box.delete(id);
  }

  @override
  Future<void> clear() async {
    final box = await _boxInstance;
    await box.clear();
  }
}
