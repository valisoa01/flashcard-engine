Groupe 34 --- Organisation et Répartition des Tâches

FlutterFire Summer Camp 2026

Projet : FlashCard Engine --- Cartes mémoires pour révision (Spaced
Repetition)
Groupe : 34
Chef de groupe : Rafanomezantsoa Tolotriniaina Valisoa
Période du projet : 2 septembre --- 16 septembre 2026
Focus technique : Algorithme Spaced Repetition en Dart pur, base de
données locale, import/export JSON.
Bonus : Synchronisation optionnelle Firestore.
État actuel : Projet Flutter initialisé, dépôt GitHub créé, branche
main protégée, branche develop créée.
Composition de l'équipe : l'ensemble des membres (y compris Achille)
ont quitté le projet le 12 septembre 2026. Valisoa poursuit désormais
le développement SEUL jusqu'à la présentation du 16 septembre.
Cette mise à jour (14 septembre) adapte le document en conséquence.

1. Objectif du document

Ce document définit l'organisation technique du Groupe 34, la stratégie
Git/GitHub et la répartition progressive des responsabilités.

L'objectif est de permettre à toute l'équipe de :

savoir qui est responsable de chaque partie ;

travailler en parallèle sans se gêner ;

comprendre le rôle de develop ;

éviter les modifications directes sur main ;

suivre les Pull Requests ;

intégrer progressivement les nouveaux membres ;

garder une base de code stable jusqu'au rendu.

Règle importante : le projet continue avec les membres disponibles.
Toutes les tâches restantes sont désormais portées par Valisoa seul
jusqu'au rendu du 16 septembre 2026.

2. Projet : FlashCard Engine

Le projet consiste à développer une application Flutter permettant de
réviser des connaissances avec un système de cartes mémoires et de
répétition espacée.

Fonctionnalités principales prévues

Gestion des decks

créer un deck ;

consulter les decks ;

modifier un deck ;

supprimer un deck.

Gestion des flashcards

créer une carte ;

afficher question/réponse ;

modifier une carte ;

supprimer une carte ;

associer une carte à un deck.

Révision

démarrer une session de révision ;

afficher une question ;

afficher la réponse ;

permettre à l'utilisateur d'indiquer la difficulté de sa réponse ;

calculer la prochaine révision ;

sauvegarder l'état de la carte.

Spaced Repetition

L'algorithme doit être implémenté en Dart pur et rester indépendant de
l'interface Flutter autant que possible.

Flux général :

Réponse de l'utilisateur
        ↓
Évaluation de la réponse
        ↓
Algorithme Spaced Repetition
        ↓
Mise à jour de la carte
        ↓
Calcul de l'intervalle
        ↓
Calcul de la prochaine date de révision
        ↓
Sauvegarde

Données

stockage local ;

import JSON ;

export JSON.

Bonus

synchronisation optionnelle avec Firestore.

Le bonus Firestore sera traité uniquement lorsque le MVP fonctionnera
correctement.

3. Architecture Git/GitHub

Branches principales

main
  ↑
develop
  ↑
feature/*

main

main représente la version stable du projet.

Personne ne doit travailler directement sur main.

La branche est protégée.

Elle doit contenir uniquement une version suffisamment stable et validée
du projet.

develop

develop est la branche centrale d'intégration de l'équipe.

Elle sert à regrouper les fonctionnalités développées par les différents
membres avant leur passage vers main.

Flux normal

Branche feature
      ↓
Développement
      ↓
Commit
      ↓
Push
      ↓
Pull Request vers develop
      ↓
Code Review
      ↓
Tests
      ↓
Merge dans develop
      ↓
Version intégrée
      ↓
Validation finale
      ↓
Merge vers main

Pourquoi utiliser develop ?

Sans develop, chaque membre pourrait essayer d'intégrer directement
son travail dans main.

Cela augmente les risques :

de casser l'application ;

d'introduire des conflits ;

d'intégrer du code non testé ;

de rendre la version stable inutilisable.

develop sert donc de zone d'intégration.

4. Règles Git de l'équipe

Règle 1 --- Pas de développement direct sur main

Interdit :

git checkout main
# modifier le code
git add .
git commit
git push

La branche main reste protégée.

Règle 2 --- Toujours partir de develop

Avant de commencer une nouvelle tâche :

git checkout develop
git pull origin develop

Puis créer une branche dédiée :

git checkout -b feature/nom-de-la-tache

Exemple :

git checkout -b feature/spaced-repetition

Règle 3 --- Une branche = une fonctionnalité ou un groupe cohérent de petites tâches

Exemples :

feature/spaced-repetition
feature/local-database
feature/json-import-export
feature/flashcard-ui
feature/deck-ui
feature/tests

Éviter une branche contenant plusieurs fonctionnalités sans rapport.

Règle 4 --- Commits clairs

Utiliser des messages explicites.

Exemples :

git commit -m "feat: implement spaced repetition algorithm"
git commit -m "feat: add flashcard model"
git commit -m "feat: add local database repository"
git commit -m "test: add spaced repetition tests"
git commit -m "fix: correct next review calculation"

════════════════════════════════════════════════════════════════════

5. RÉPARTITION DES RESPONSABILITÉS (point important)

L'équipe comptait 6 personnes au départ (le chef de groupe plus 5
coéquipiers listés sur le projet). À la date du 12 septembre 2026, tous
les coéquipiers (dont Achille) ont quitté le projet. Depuis, Valisoa
(chef de groupe) développe l'application seul et reprend toutes les
tâches restantes, y compris le Spaced Repetition initialement confié à
Achille.

Valisoa (Chef de groupe) : Architecture, Modèles, Base de données,
                              Interface (UI), Intégration, JSON,
                              Spaced Repetition, Tests, Documentation,
                              Démo.

⚠️ À partir de maintenant, TOUTES les tâches (T-08 à T-24) sont gérées
   par Valisoa seul. Les conventions Git restent appliquées (branche
   feature, PR vers develop).

La répartition suit le principe suivant :

Un module = une personne responsable.

Un seul membre est désormais actif. Il reprend tous les modules restants.

Valisoa (Chef de groupe) : Architecture, Modèles, Base de données,
                              Interface (UI), Intégration, JSON,
                              Spaced Repetition, Documentation.

Pour éviter toute confusion :

toutes les tâches restantes (UI, JSON, Spaced Repetition, tests,
  intégration, démo) reviennent à Valisoa.

Important : le développement se fait en solo mais reste organisé par
branches feature pour garder un historique propre jusqu'au rendu.

════════════════════════════════════════════════════════════════════

6. 👑 Valisoa --- Chef de Groupe

Responsabilité principale

Architecture, coordination, base de données, modèles, interface et
intégration.

Tâches transverses

mettre en place la structure du projet ;

définir l'architecture ;

définir les modèles de données ;

choisir et configurer la base de données locale ;

développer les écrans (UI) ;

implémenter l'import/export JSON ;

coordonner les branches ;

suivre les Pull Requests ;

effectuer les code reviews ;

intégrer les fonctionnalités dans develop ;

vérifier que les différentes parties fonctionnent ensemble ;

suivre le backlog et le Google Sheet ;

communiquer avec le mentor ;

préparer progressivement la démonstration.

Branches déjà créées

feature/models
feature/local-database
feature/project-architecture
feature/home-ui
feature/ma-modification
doc/task

Série de tâches de Valisoa (T-01 à T-08)

┌──────┬──────────────────────┬──────────────────┬──────────────────┐
│ ID   │ Tâche                │ Branche          │ Statut           │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-01 │ Architecture du      │ feature/ma-      │ ✅ Terminé       │
│      │ projet Flutter       │ modification     │ (PR #1)          │
│      │ (structure GitHub)   │                  │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-02 │ Créer les modèles    │ feature/models   │ ✅ Terminé       │
│      │ Deck, Flashcard,     │                  │ (PR #3)          │
│      │ Review               │                  │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-03 │ Document task.md     │ doc/task         │ ✅ Terminé       │
│      │ (répartition tâches) │                  │ (PR #2)          │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-04 │ Architecture lib/    │ feature/project- │ ✅ Terminé       │
│      │ + structurer les     │ architecture     │ (PR #4)          │
│      │ dossiers             │                  │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-05 │ Choisir et configurer│ feature/local-   │ ✅ Terminé       │
│      │ la database locale   │ database         │ (PR #6)          │
│      │ (Hive)               │                  │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-06 │ Repository Deck et   │ feature/local-   │ ✅ Terminé       │
│      │ Repository Flashcard │ database         │ (PR #6)          │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-07 │ Écran Home (liste    │ feature/home-ui  │ ✅ Terminé       │
│      │ + création decks)    │                  │ (PR #7)          │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-08 │ Écran Deck + gestion │ feature/deck-ui  │ ✅ Terminé       │
│      │ des flashcards       │                  │ (PR #11)         │
└──────┴──────────────────────┴──────────────────┴──────────────────┘

Tâches terminées par Valisoa seul (14 septembre)

✅ T-09 Écran Study (révision)                 → feature/study-ui
✅ T-13 à T-17 Spaced Repetition (repris)      → feature/spaced-repetition
✅ T-10 Import / Export JSON                   → feature/json-import-export
✅ T-11 Intégration complète                   → feature/integration
✅ T-12 README final + démo                    → feature/documentation
🟡 T-24 Démo / présentation (16 septembre)     → feature/presentation
   (guide de présentation PRESENTATION.md créé ; captures restantes)

Note : un ami rejoint pour la PRÉSENTATION uniquement (pas de code).
Il doit lire PRESENTATION.md pour aider à présenter le projet.

════════════════════════════════════════════════════════════════════

7. Spaced Repetition --- repris par Valisoa (départ d'Achille)

⚠️ Achille a quitté le projet le 12 septembre 2026. Les tâches T-13 à
T-17 n'ont PAS été commencées (aucun fichier poussé sur GitHub).
Valisoa reprend l'intégralité du module Spaced Repetition.

Responsabilité principale

Algorithme de répétition espacée et tests associés (Dart pur).

Tâches (reprises)

définir les règles de calcul ;

implémenter le service de répétition espacée ;

garder l'algorithme indépendant de Flutter (Dart pur) ;

gérer les différents niveaux de réponse ;

calculer l'intervalle suivant ;

calculer la prochaine date de révision ;

écrire les tests unitaires ;

documenter les règles utilisées.

Branche proposée

feature/spaced-repetition

Série de tâches Spaced Repetition (T-13 à T-17, reprises par Valisoa)

┌──────┬──────────────────────┬──────────────────┬──────────────────┐
│ ID   │ Tâche                │ Détail           │ Statut           │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-13 │ Définir les règles   │ Choix du modèle  │ 🔴 À faire       │
│      │ du Spaced Repetition │ (SM-2, Anki,     │ (repris,         │
│      │                      │ Leitner...).     │ Achille parti)   │
│      │                      │ Documenter dans  │                  │
│      │                      │ lib/services/    │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-14 │ Implémenter le       │ Créer            │ 🔴 À faire       │
│      │ service              │ spaced_          │ (repris,         │
│      │                      │ repetition.dart  │ Achille parti)   │
│      │                      │ (Dart pur)       │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-15 │ Calculer les         │ À partir du      │ 🔴 À faire       │
│      │ intervalles          │ niveau de        │ (repris)         │
│      │                      │ réponse          │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-16 │ Calculer nextReview  │ Mettre à jour    │ 🔴 À faire       │
│      │                      │ la date de       │ (repris)         │
│      │                      │ révision de la   │                  │
│      │                      │ Flashcard        │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-17 │ Ajouter les tests    │ test/spaced_     │ 🔴 À faire       │
│      │ unitaires            │ repetition_test  │ (repris)         │
│      │                      │ .dart            │                  │
└──────┴──────────────────────┴──────────────────┴──────────────────┘

Modèle de données utilisable (existants)

Le modèle Review existe déjà (créé par Valisoa dans lib/models/
review.dart). Il contient :

enum ReviewQuality { again, hard, good, easy }

class Review {
  String flashcardId;
  ReviewQuality quality;
  int previousInterval;
  int newInterval;
  double previousEaseFactor;
  double newEaseFactor;
  DateTime reviewedAt;
}

Le modèle Flashcard contient les champs à mettre à jour par l'algorithme
:

int repetitions;
int interval;
double easeFactor;
DateTime nextReview;

Valisoa doit utiliser CES modèles existants et NON en créer de nouveaux,
pour que l'algorithme s'intègre directement avec la base de données.

Arborescence de travail

lib/
  services/
    spaced_repetition_service.dart   → à créer
test/
  spaced_repetition_service_test.dart → à créer

Règle : l'algorithme ne doit jamais importer package:flutter. Il reste
100% Dart pur.

════════════════════════════════════════════════════════════════════

8. Note sur les anciens membres (départ de l'équipe)

Tous les coéquipiers ont quitté le projet. Aucun nouveau membre ne
rejoint le groupe avant le rendu. La procédure d'intégration ci-dessous
est conservée uniquement à titre informatif.

Lorsqu'un nouveau membre rejoignait le groupe :

renseigner ses informations dans le Google Sheet ;

identifier son niveau ;

identifier ses compétences ;

lui attribuer une tâche adaptée ;

créer sa branche ;

lui expliquer le workflow Git ;

suivre son avancement ;

vérifier sa contribution via commit ou Pull Request.

Exemple :

Membre rejoint
      ↓
Évaluation des compétences
      ↓
Choix d'une tâche
      ↓
Création de branche
      ↓
Développement
      ↓
Pull Request
      ↓
Review
      ↓
Merge dans develop

Tâches à attribuer aux nouveaux membres (disponibles)

Important : toutes ces tâches sont désormais exécutées par Valisoa seul
avant le 16 septembre.

┌──────┬──────────────────────────┬──────────────────────────┐
│ ID   │ Tâche                    │ Prise en charge          │
├──────┼──────────────────────────┼──────────────────────────┤
│ T-B1 │ Écran Study (UI)         │ Valisoa (fuse avec T-09) │
│ T-B2 │ Import JSON              │ Valisoa (fuse avec T-10) │
│ T-B3 │ Export JSON              │ Valisoa (fuse avec T-10) │
│ T-B4 │ Tests Database           │ Valisoa                  │
│ T-B5 │ Tests JSON               │ Valisoa                  │
│ T-B6 │ QA / correction bugs     │ Valisoa                  │
│ T-B7 │ Bonus Firestore          │ ✅ Implémenté            │
└──────┴──────────────────────────┴──────────────────────────┘

════════════════════════════════════════════════════════════════════

9. Backlog détaillé et suivi (à reporter dans le Google Sheet)

Légende des statuts :

[À faire]   → tâche pas encore commencée
[En cours]  → développement en cours
[En review] → PR créée, en attente de validation
[Terminé]   → mergé dans develop

┌──────┬──────────────────────────┬───────────────┬───────────────┬──────────────┬──────────────────────┐
│ ID   │ Tâche                    │ Module        │ Responsable   │ Statut       │ Lien PR              │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-01 │ Initialisation du projet │ Architecture  │ Valisoa       │ Terminé      │ PR #1                │
│      │ + structure GitHub       │               │               │              │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-02 │ Modèles Deck, Flashcard, │ Models        │ Valisoa       │ Terminé      │ PR #3                │
│      │ Review                   │               │               │              │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-03 │ Document task.md         │ Documentation │ Valisoa       │ Terminé      │ PR #2                │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-04 │ Architecture lib/ +      │ Architecture  │ Valisoa       │ Terminé      │ PR #4                │
│      │ dossiers                 │               │               │              │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-05 │ Database locale (Hive)   │ Database      │ Valisoa       │ Terminé      │ PR #6                │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-06 │ Repository Deck +        │ Database      │ Valisoa       │ Terminé      │ PR #6                │
│      │ Repository Flashcard     │               │               │              │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-07 │ Écran Home               │ UI            │ Valisoa       │ Terminé      │ PR #7                │
│      │                          │               │               │              │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-08 │ Écran Deck + flashcards  │ UI            │ Valisoa       │ Terminé      │ PR #11               │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-09 │ Écran Study              │ UI            │ Valisoa       │ Terminé      │ feature/study-ui     │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-10 │ Import/Export JSON       │ JSON          │ Valisoa       │ Terminé      │ feature/json-import- │
│      │                          │               │               │              │ export               │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-11 │ Intégration complète     │ Integration   │ Valisoa       │ Terminé      │ feature/integration  │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-12 │ README final + démo      │ Documentation │ Valisoa       │ Terminé      │ feature/documentation│
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-13 │ Règles Spaced Repetition │ Spaced        │ Valisoa       │ Terminé      │ feature/spaced-      │
│      │                          │ Repetition    │ (repris)      │              │ repetition           │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-14 │ Service Spaced           │ Spaced        │ Valisoa       │ Terminé      │ feature/spaced-      │
│      │ Repetition               │ Repetition    │ (repris)      │              │ repetition           │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-15 │ Calcul des intervalles   │ Spaced        │ Valisoa       │ Terminé      │ feature/spaced-      │
│      │                          │ Repetition    │ (repris)      │              │ repetition           │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-16 │ Calcul nextReview        │ Spaced        │ Valisoa       │ Terminé      │ feature/spaced-      │
│      │                          │ Repetition    │ (repris)      │              │ repetition           │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-17 │ Tests unitaires SR       │ Tests         │ Valisoa       │ Terminé      │ feature/spaced-      │
│      │                          │               │ (repris)      │              │ repetition           │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-24 │ Démo / présentation      │ Demo          │ Valisoa + ami  │ 🟡 En cours │ feature/            │
│      │                          │               │ (présentation)│ (guide créé)│ presentation         │
└──────┴──────────────────────────┴───────────────┴───────────────┴──────────────┴──────────────────────┘

Plan des 2 jours restants (14 → 16 septembre)

Dimanche 14 septembre : ✅ fait
- Spaced Repetition (T-13 à T-17) : règles SM-2, service Dart pur, 11 tests.
- Écran Study (T-09) : session de révision reliée au service SR + tests.
- Import / Export JSON (T-10) + tests.
- Intégration (T-11) : test de parcours complet, 34 tests au total verts.

Lundi 15 septembre :
- Dernière revue : `flutter test` + `flutter analyze` sur develop.
- README final (T-12) : ✅ fait.
- Guide de présentation (T-24) : ✅ PRESENTATION.md créé (à partager
  avec l'ami qui présente).
- Captures d'écran / GIFs pour le support de présentation.

Mardi 16 septembre (J-0) :
- Démo / présentation (T-24), revue finale avec le mentor.

Note importante sur l'état du Spaced Repetition

Au moment de la mise à jour du 14 septembre, aucune branche
feature/spaced-repetition ni aucun commit n'avait été poussé sur GitHub
pour les tâches T-13 à T-17. Depuis, elles ont été reprises et terminées
par Valisoa ce jour même (service SM-2 + 11 tests unitaires, mergé dans
develop).

10. Règles de Pull Request

Lorsqu'une tâche est terminée :

1. Vérifier le code
2. Exécuter les tests
3. Commit
4. Push
5. Créer une Pull Request vers develop
6. Ajouter une description
7. Demander une review
8. Corriger si nécessaire
9. Merge après validation

Exemple de titre :

feat: implement spaced repetition algorithm

Description minimale :

## Objectif
Implémenter le calcul de répétition espacée.

## Modifications
- ajout du service SpacedRepetitionService
- calcul de l'intervalle
- calcul de nextReview

## Tests
- tests des différents niveaux de réponse

## Issue
T-14

11. Règle de synchronisation avant développement

Avant de commencer une tâche :

git checkout develop
git pull origin develop
git checkout -b feature/ma-tache

Pendant le développement :

git add .
git commit -m "feat: description"
git push -u origin feature/ma-tache

Après intégration de la branche dans develop, supprimer la branche si
elle n'est plus nécessaire.

12. Suivi quotidien

L'équipe n'étant plus active, le stand-up est remplacé par un suivi
personnel de Valisoa, consigné dans ce document (statuts du backlog) et
par commit. Les 3 questions restent utiles :

1. Qu'as-tu fait hier ?

Exemple :

J'ai terminé le modèle Flashcard.

2. Que fais-tu aujourd'hui ?

Je vais travailler sur le service Spaced Repetition.

3. As-tu un blocage ?

Non.

ou :

Oui, problème avec le calcul de nextReview.

Tout blocage important doit être remonté rapidement.

13. Règles de communication

prévenir l'équipe en cas d'absence prolongée ;

signaler rapidement les blocages ;

ne pas attendre plusieurs jours avant de demander de l'aide ;

respecter les décisions techniques prises collectivement ;

faire des code reviews constructives ;

éviter les modifications non communiquées dans les parties communes
;

documenter les choix techniques importants.

14. Priorités du projet

L'ordre de priorité est :

1. Fonctionnement du MVP
2. Qualité et stabilité
3. Tests
4. Documentation
5. Interface et finition
6. Bonus Firestore

Le bonus ne doit pas retarder le MVP.

15. Objectif de livraison

Avant le 16 septembre 2026, Valisoa doit disposer (seul) d'une version
démontrable et stable.

La préparation finale doit comprendre :

application fonctionnelle ;

tests principaux ;

données persistantes ;

import/export JSON fonctionnel ;

README ;

captures ou GIFs ;

scénario de démonstration ;

présentation ;

revue finale avec le mentor.

Le guide prévoit également un freeze du code à J-3, un audit des
certifications à J-2 et une revue finale avec le mentor.

16. Règle fondamentale du Groupe 34

Nous avançons avec les membres disponibles. Nous n'attendons pas les
membres absents pour commencer.

L'équipe étant partie, le développement est poursuivi seul par Valisoa
jusqu'à la présentation du 16 septembre.

17. État actuel (mise à jour du 14 septembre)

GitHub                     ✅
main protégée              ✅
Projet Flutter initialisé  ✅
develop                    ✅

Architecture               ✅
Modèles                    ✅
Database locale (Hive)     ✅
Repositories               ✅
Écran Home                 ✅ Terminé
Écran Deck                 ✅ Terminé (PR #11)
Spaced Repetition          ✅ Terminé (repris par Valisoa, 11 tests)
Écran Study                ✅ Terminé
Import/Export JSON         ✅ Terminé
Intégration                ✅ Terminé (34 tests verts)
Tests                      ✅ 34 tests passants + analyse propre
Documentation              ✅ README final (feature/documentation)
Démo                       ⏳ 16 septembre

Prochaine étape recommandée :

Merge feature/documentation (T-12) dans develop
     ↓
Vérification finale : flutter test + flutter analyze
     ↓
Scénario de démo + captures (T-24)
     ↓
Présentation du 16 septembre
