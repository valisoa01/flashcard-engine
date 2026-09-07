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
Composition de l'équipe : équipe de 5 personnes listées. Seuls 2 sont
actifs (Valisoa et Achille). Les autres membres n'ont pas participé pour
l'instant.

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

Règle importante : le projet avance avec les membres actuellement
disponibles. Les membres qui rejoindront le groupe plus tard seront
intégrés progressivement sur les tâches restantes.

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

L'équipe était composée de 6 personnes au départ (le chef de groupe
plus 5 coéquipiers listés sur le projet). À ce jour seuls 2 membres sont
actifs et contribuent au projet :

Valisoa (Chef de groupe) : Chef de groupe.
Achille : Développeur Spaced Repetition.

Les autres membres inscrits (benedicte, sawadogoahmedelamine,
ouedmarina, abel) n'ont pas encore participé au développement. S'ils
 rejoignent le
projet plus tard, ils seront intégrés progressivement sur les tâches
restantes (voir section 8).

Conformément à la règle 16 : le projet avance avec les membres
actuellement disponibles. On n'attend pas les membres absents pour
commencer.

La répartition suit le principe suivant :

Un module = une personne responsable.

Chaque membre travaille sur SA branche et ne modifie pas le travail des
autres.

Les deux membres actifs se partagent ainsi les modules :

Valisoa (Chef de groupe) : Architecture, Modèles, Base de données,
                              Interface (UI), Intégration, JSON,
                              Documentation.

Achille : Spaced Repetition (algorithme pur + tests).

Pour éviter toute confusion :

les tâches à ORIENTATION TECHNIQUE et VISUELLE (modèles, base de
données, écrans, JSON) reviennent à Valisoa en attendant que d'autres
membres rejoignent le groupe ;

les tâches de LOGIQUE PURE (algorithme Spaced Repetition) reviennent
à Achille.

Important : le développement se fait EN PARALLÈLE. Achille peut
commencer l'algorithme sans attendre Valisoa, et inversement, car les
deux modules sont indépendants.

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

Série de tâches de Valisoa (T-01 à T-07)

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
│ T-07 │ Écran Home (liste    │ feature/home-ui  │ 🟡 En review    │
│      │ + création decks)    │                  │ (à merger dans  │
│      │                      │                  │ develop)        │
└──────┴──────────────────────┴──────────────────┴──────────────────┘

Tâches suivantes de Valisoa

T-08 Écran Deck (+ gestion des flashcards)  → feature/deck-ui
T-09 Écran Study (révision)                 → feature/study-ui
T-10 Import / Export JSON                   → feature/json-import-export
T-11 Intégration complète                   → feature/integration
T-12 README final + démo                    → feature/documentation

════════════════════════════════════════════════════════════════════

7. Achille --- Développement Spaced Repetition

Responsabilité principale

Algorithme de répétition espacée et tests associés.

Tâches

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

Série de tâches d'Achille (T-13 à T-17)

┌──────┬──────────────────────┬──────────────────┬──────────────────┐
│ ID   │ Tâche                │ Détail           │ Statut           │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-13 │ Définir les règles   │ Choix du modèle  │ 🟡 En cours /    │
│      │ du Spaced Repetition │ (SM-2, Anki,     │ À faire          │
│      │                      │ Leitner...).     │                  │
│      │                      │ Documenter dans  │                  │
│      │                      │ lib/services/    │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-14 │ Implémenter le       │ Créer            │ 🟡 En cours /    │
│      │ service              │ spaced_          │ À faire          │
│      │                      │ repetition.dart  │                  │
│      │                      │ (Dart pur)       │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-15 │ Calculer les         │ À partir du      │ 🟡 En cours /    │
│      │ intervalles          │ niveau de        │ À faire          │
│      │                      │ réponse          │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-16 │ Calculer nextReview  │ Mettre à jour    │ 🟡 En cours /    │
│      │                      │ la date de       │ À faire          │
│      │                      │ révision de la   │                  │
│      │                      │ Flashcard        │                  │
├──────┼──────────────────────┼──────────────────┼──────────────────┤
│ T-17 │ Ajouter les tests    │ test/spaced_     │ 🟡 En cours /    │
│      │ unitaires            │ repetition_test  │ À faire          │
│      │                      │ .dart            │                  │
└──────┴──────────────────────┴──────────────────┴──────────────────┘

Modèle de données utilisable par Achille

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

Achille doit utiliser CES modèles existants et NON en créer de nouveaux,
pour que l'algorithme s'intègre directement avec la base de données.

Arborescence de travail pour Achille

lib/
  services/
    spaced_repetition_service.dart   → à créer
test/
  spaced_repetition_service_test.dart → à créer

Règle : l'algorithme ne doit jamais importer package:flutter. Il reste
100% Dart pur.

════════════════════════════════════════════════════════════════════

8. Membres qui rejoindront plus tard

Les membres absents ne doivent pas être oubliés.

Lorsqu'un nouveau membre rejoint le groupe :

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

Important : tant qu'aucun nouveau membre n'a rejoint, ces tâches sont
reprises par Valisoa (ou réparties avec Achille si l'une concerne le
Spaced Repetition).

┌──────┬──────────────────────────┬──────────────────────────┐
│ ID   │ Tâche                    │ Branche suggérée         │
├──────┼──────────────────────────┼──────────────────────────┤
│ T-B1 │ Écran Study (UI)         │ feature/study-ui         │
│ T-B2 │ Import JSON              │ feature/json-import-export│
│ T-B3 │ Export JSON              │ feature/json-import-export│
│ T-B4 │ Tests Database           │ feature/tests            │
│ T-B5 │ Tests JSON               │ feature/tests            │
│ T-B6 │ QA / correction bugs     │ feature/qa               │
│ T-B7 │ Bonus Firestore          │ feature/firestore-sync   │
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
│ T-08 │ Écran Deck + flashcards  │ UI            │ Valisoa       │ À faire      │ —                    │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-09 │ Écran Study              │ UI            │ Valisoa       │ À faire      │ —                    │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-10 │ Import/Export JSON       │ JSON          │ Valisoa       │ À faire      │ —                    │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-11 │ Intégration complète     │ Integration   │ Valisoa       │ À faire      │ —                    │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-12 │ README final + démo      │ Documentation │ Valisoa       │ À faire      │ —                    │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-13 │ Règles Spaced Repetition │ Spaced        │ Achille       │ En cours /   │ —                    │
│      │                          │ Repetition    │               │ À faire      │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-14 │ Service Spaced           │ Spaced        │ Achille       │ En cours /   │ —                    │
│      │ Repetition               │ Repetition    │               │ À faire      │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-15 │ Calcul des intervalles   │ Spaced        │ Achille       │ En cours /   │ —                    │
│      │                          │ Repetition    │               │ À faire      │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-16 │ Calcul nextReview        │ Spaced        │ Achille       │ En cours /   │ —                    │
│      │                          │ Repetition    │               │ À faire      │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-17 │ Tests unitaires SR       │ Tests         │ Achille       │ En cours /   │ —                    │
│      │                          │               │               │ À faire      │                      │
├──────┼──────────────────────────┼───────────────┼───────────────┼──────────────┼──────────────────────┤
│ T-24 │ Démo / présentation      │ Demo          │ Toute l'équipe│ À faire      │ —                    │
└──────┴──────────────────────────┴───────────────┴───────────────┴──────────────┴──────────────────────┘

Note importante sur l'état d'Achille

Au moment de cette mise à jour, aucune branche feature/spaced-repetition
ni aucun commit n'a encore été poussé sur GitHub pour les tâches T-13 à
T-17. Ces tâches sont notées « En cours / À faire ». Il faut vérifier
avec Achille s'il a commencé en local.

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

Chaque jour, l'équipe réalise un stand-up de 10 à 15 minutes.

Chaque membre répond :

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

Avant le 16 septembre 2026, le groupe doit disposer d'une version
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

Les nouveaux membres seront intégrés progressivement et recevront des
tâches adaptées.

L'objectif n'est pas qu'une seule personne fasse tout le projet.

L'objectif est que chaque membre contribue réellement au projet et
progresse pendant le Summer Camp.

17. État actuel

GitHub                     ✅
main protégée              ✅
Projet Flutter initialisé  ✅
develop                    ✅

Architecture               ✅
Modèles                    ✅
Database locale (Hive)     ✅
Repositories               ✅
Écran Home                 ✅ Terminé
Spaced Repetition          🟡 (en cours par Achille)
Écran Deck                 ⏳
Écran Study                ⏳
Import/Export JSON         ⏳
Tests                      ⏳
Documentation              ⏳
Démo                       ⏳

Prochaine étape recommandée :

Écran Deck + Flashcards (Valisoa)
     ↓
Écran Study (Valisoa)
     ↓
Import/Export JSON (Valisoa)
     ↓
Intégration complète
     ↓
Démo
