import 'package:hive/hive.dart';

import '../models/deck.dart';
import 'deck_repository.dart';

class HiveDeckRepository implements DeckRepository {
  static const _boxName = 'decks';

  Box<dynamic>? _box;

  Future<Box<dynamic>> get _boxInstance async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    return _box!;
  }

  @override
  Future<List<Deck>> getAll() async {
    final box = await _boxInstance;
    return box.values
        .map((value) => Deck.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  @override
  Future<Deck?> getById(String id) async {
    final box = await _boxInstance;
    final value = box.get(id);
    if (value == null) return null;
    return Deck.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<void> save(Deck deck) async {
    final box = await _boxInstance;
    await box.put(deck.id, deck.toJson());
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
