# FlashCard Engine

Application Flutter de cartes mémoires avec répétition espacée
(Spaced Repetition) pour réviser efficacement.

Projet du FlutterFire Summer Camp 2026 --- Groupe 34.
Période : 2 septembre --- 16 septembre 2026.

## Fonctionnalités

- **Gestion des decks** : créer, consulter, modifier et supprimer des decks.
- **Gestion des flashcards** : créer, afficher, modifier et supprimer des
  cartes (question / réponse) associées à un deck.
- **Révision (Study)** : session de révision qui affiche les cartes à
  revoir, laisse retourner la carte, et demande à l'utilisateur d'évaluer
  sa réponse (Encore / Difficile / Bien / Facile).
- **Spaced Repetition** : algorithme SM-2 implémenté en Dart pur qui
  met à jour automatiquement l'intervalle, le facteur de facilité et la
  date de prochaine révision de chaque carte.
- **Stockage local** : base de données locale Hive (persistance des decks
  et des cartes).
- **Import / Export JSON** : exporte toutes les données dans un fichier
  JSON et permet de les réimporter.
- **Synchronisation Firestore (bonus)** : pousse les données locales vers
  Cloud Firestore ou les récupère (icône nuage sur l'écran d'accueil).

## Architecture

```
lib/
  models/        Modèles Deck, Flashcard, Review (avec JSON)
  repositories/  Interfaces + implémentation Hive
  screens/       Écrans Home, Deck, Study, Détail carte
  services/      Spaced Repetition Service, Json Service (Dart pur)
  app.dart       Widget racine de l'application
test/
  ...            Tests unitaires et tests de widgets
```

L'algorithme Spaced Repetition (`lib/services/spaced_repetition_service.dart`)
est volontairement écrit en Dart pur : aucune dépendance à Flutter, il peut
être testé et réutilisé indépendamment de l'interface.

## Règles de l'algorithme (SM-2)

- Ease Factor initial : 2.5, minimum : 1.3.
- Réponse « Encore » : la carte repart à zéro et est à revoir le lendemain.
- Réponse réussie (Difficile / Bien / Facile) : `repetitions + 1`, puis
  intervalle suivant : 1 jour, puis 6 jours, puis `intervalle × ease factor`
  (avec un bonus pour « Facile »).
- Date de prochaine révision = date de révision + intervalle (jours).

## Démarrage

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Le projet contient des tests unitaires (algorithme SM-2, service JSON,
repositories Hive) et des tests de widgets (écrans Home, Deck, Study,
parcours d'intégration complet).

## Scénario de démonstration

1. Créer un deck (bouton `+` sur l'écran d'accueil).
2. Ouvrir le deck et créer quelques cartes (`+`).
3. Toucher **Réviser** pour démarrer une session.
4. Afficher la réponse, puis noter la carte (Encore / Difficile / Bien /
   Facile).
5. Exporter / réimporter les données via les boutons JSON de l'accueil.

## Synchronisation Firestore (bonus)

La synchronisation est **optionnelle** et désactivée si Firebase n'est pas
configuré (l'application fonctionne alors normalement en local).

Pour l'activer :

1. Créer un projet sur la console Firebase.
2. Ajouter l'application correspondante (Android, iOS, Web...).
3. Placer `google-services.json` dans `android/app/` (et les fichiers
   équivalents selon la plateforme).
4. Définir les règles de Firestore en mode test pour la démonstration.
5. Relancer l'application : l'icône **nuage** de l'écran d'accueil permet
   alors de **Pousser** les données vers Firestore ou de les **Récupérer**.

## Configuration Git

- Branche `main` : version stable (protégée).
- Branche `develop` : zone d'intégration.
- Branches `feature/*` : une branche par fonctionnalité, fusionnées dans
  `develop` via Pull Request.