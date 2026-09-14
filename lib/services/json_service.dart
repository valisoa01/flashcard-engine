import 'dart:convert';

import '../models/deck.dart';
import '../models/flashcard.dart';

class JsonExport {
  final String version;
  final DateTime exportedAt;
  final List<Deck> decks;
  final List<Flashcard> flashcards;

  const JsonExport({
    required this.version,
    required this.exportedAt,
    required this.decks,
    required this.flashcards,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'decks': decks.map((deck) => deck.toJson()).toList(),
      'flashcards': flashcards.map((card) => card.toJson()).toList(),
    };
  }

  factory JsonExport.fromJson(Map<String, dynamic> json) {
    return JsonExport(
      version: json['version'] as String? ?? '1',
      exportedAt:
          DateTime.tryParse(json['exportedAt'] as String? ?? '') ??
              DateTime.now(),
      decks: (json['decks'] as List<dynamic>? ?? [])
          .map((value) => Deck.fromJson(Map<String, dynamic>.from(value)))
          .toList(),
      flashcards: (json['flashcards'] as List<dynamic>? ?? [])
          .map((value) =>
              Flashcard.fromJson(Map<String, dynamic>.from(value)))
          .toList(),
    );
  }
}

class JsonService {
  static const _currentVersion = '1';

  String exportAll({
    required List<Deck> decks,
    required List<Flashcard> flashcards,
  }) {
    final export = JsonExport(
      version: _currentVersion,
      exportedAt: DateTime.now(),
      decks: decks,
      flashcards: flashcards,
    );
    return const JsonEncoder.withIndent('  ').convert(export.toJson());
  }

  JsonExport parse(String rawJson) {
    if (rawJson.trim().isEmpty) {
      throw const FormatException('JSON vide.');
    }
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Le fichier doit être un objet JSON.');
    }
    return JsonExport.fromJson(decoded);
  }
}