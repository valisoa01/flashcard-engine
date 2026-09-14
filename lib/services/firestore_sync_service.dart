import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/deck.dart';
import '../models/flashcard.dart';
import '../repositories/deck_repository.dart';
import '../repositories/flashcard_repository.dart';

class SyncResult {
  final int pushedDecks;
  final int pushedFlashcards;
  final int pulledDecks;
  final int pulledFlashcards;

  const SyncResult({
    this.pushedDecks = 0,
    this.pushedFlashcards = 0,
    this.pulledDecks = 0,
    this.pulledFlashcards = 0,
  });

  @override
  String toString() {
    return 'Poussé : $pushedDecks deck(s), $pushedFlashcards carte(s). '
        'Récupéré : $pulledDecks deck(s), $pulledFlashcards carte(s).';
  }
}

class FirestoreSyncService {
  FirestoreSyncService({
    required DeckRepository deckRepository,
    required FlashcardRepository flashcardRepository,
  })  : _decks = deckRepository,
        _cards = flashcardRepository;

  final DeckRepository _decks;
  final FlashcardRepository _cards;

  static const _decksCollection = 'decks';
  static const _cardsCollection = 'flashcards';

  bool? _initialized;

  /// Initialise Firebase. Retourne false si la configuration Firebase n'est
  /// pas présente (cas desktop sans google-services.json). Dans ce cas, la
  /// synchronisation reste désactivée sans bloquer l'application.
  Future<bool> get isAvailable async {
    if (_initialized != null) return _initialized!;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
    return _initialized!;
  }

  Future<SyncResult> pushAll() async {
    if (!await isAvailable) {
      throw StateError('Firebase n\u{2019}est pas configuré.');
    }

    final firestore = FirebaseFirestore.instance;
    var pushedDecks = 0;
    var pushedCards = 0;

    for (final deck in await _decks.getAll()) {
      await firestore
          .collection(_decksCollection)
          .doc(deck.id)
          .set(deck.toJson());
      pushedDecks++;
    }
    for (final card in await _cards.getAll()) {
      await firestore
          .collection(_cardsCollection)
          .doc(card.id)
          .set(card.toJson());
      pushedCards++;
    }

    return SyncResult(pushedDecks: pushedDecks, pushedFlashcards: pushedCards);
  }

  Future<SyncResult> pullAll() async {
    if (!await isAvailable) {
      throw StateError('Firebase n\u{2019}est pas configuré.');
    }

    final firestore = FirebaseFirestore.instance;
    final decks = await firestore.collection(_decksCollection).get();
    final cards = await firestore.collection(_cardsCollection).get();

    for (final doc in decks.docs) {
      await _decks.save(
        Deck.fromJson({...doc.data(), 'id': doc.id}),
      );
    }
    for (final doc in cards.docs) {
      await _cards.save(
        Flashcard.fromJson({...doc.data(), 'id': doc.id}),
      );
    }

    return SyncResult(
      pulledDecks: decks.docs.length,
      pulledFlashcards: cards.docs.length,
    );
  }
}