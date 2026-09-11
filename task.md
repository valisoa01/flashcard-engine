Groupe 34 --- Organisation et Répartition des Tâches

FlutterFire Summer Camp 2026

Projet : FlashCard Engine --- Cartes mémoires pour révision (Spaced
Repetition)
Groupe : 34
Chef de groupe : Rafanomezantsoa Tolotriniaina Valisoa
Date limite : 16 septembre 2026
État actuel : Projet Flutter initialisé, dépôt GitHub créé, branche
main protégée, branche develop créée.

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

5. Répartition actuelle de l'équipe

À la date de rédaction de ce document, deux membres sont disponibles
pour commencer le projet.

👑 Valisoa --- Chef de Groupe

Responsabilité principale

Architecture, coordination et intégration.

Tâches initiales

mettre en place la structure du projet ;

définir l'architecture ;

définir les modèles de données ;

coordonner les branches ;

suivre les Pull Requests ;

effectuer les code reviews ;

intégrer les fonctionnalités dans develop ;

vérifier que les différentes parties fonctionnent ensemble ;

suivre le backlog ;

communiquer avec le mentor ;

préparer progressivement la démonstration.

Branche proposée

feature/project-architecture

Première série de tâches

T-01 — Définir l'architecture du projet
T-02 — Créer les modèles Deck et Flashcard
T-03 — Préparer la structure des dossiers
T-04 — Vérifier l'intégration avec develop

6. Achille --- Développement Spaced Repetition

Responsabilité principale

Algorithme de répétition espacée et tests associés.

Tâches initiales

définir les règles de calcul ;

implémenter le service de répétition espacée ;

garder l'algorithme indépendant de Flutter ;

gérer les différents niveaux de réponse ;

calculer l'intervalle suivant ;

calculer la prochaine date de révision ;

écrire les tests unitaires ;

documenter les règles utilisées.

Branche proposée

feature/spaced-repetition

Première série de tâches

T-05 — Définir les règles du Spaced Repetition
T-06 — Implémenter le service Spaced Repetition
T-07 — Calculer l'intervalle suivant
T-08 — Calculer nextReview
T-09 — Ajouter les tests unitaires

7. Membres qui rejoindront plus tard

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

8. Backlog initial du projet

Le backlog sera complété et ajusté après validation de l'architecture.

ID             Module          Tâche                Priorité       Responsable
initial

T-01           Architecture    Définir              Haute          Valisoa
l'architecture
Flutter

T-02           Models          Créer le modèle      Haute          Valisoa
Flashcard

T-03           Models          Créer le modèle Deck Haute          Valisoa

T-04           Project         Structurer les       Haute          Valisoa
dossiers

T-05           Spaced          Définir les règles   Haute          Achille
Repetition

T-06           Spaced          Implémenter          Haute          Achille
Repetition      l'algorithme

T-07           Spaced          Calculer les         Haute          Achille
Repetition      intervalles

T-08           Spaced          Calculer nextReview  Haute          Achille
Repetition

T-09           Tests           Tester l'algorithme  Haute          Achille

T-10           Database        Choisir/configurer   Haute          À attribuer
le stockage local

T-11           Database        Repository Deck      Haute          À attribuer

T-12           Database        Repository Flashcard Haute          À attribuer

T-13           UI              Écran Home           Haute          À attribuer

T-14           UI              Écran Deck           Haute          À attribuer

T-15           UI              Écran Study          Haute          À attribuer

T-16           UI              Création de          Moyenne        À attribuer
Flashcard

T-17           UI              Modification de      Moyenne        À attribuer
Flashcard

T-18           JSON            Import JSON          Haute          À attribuer

T-19           JSON            Export JSON          Haute          À attribuer

T-20           Tests           Tests Database       Haute          À attribuer

T-21           Tests           Tests JSON           Moyenne        À attribuer

T-22           Integration     Intégration complète Haute          Valisoa

T-23           QA              Correction des bugs  Haute          Toute l'équipe

T-24           Documentation   README final         Haute          Valisoa +
équipe

T-25           Demo            Préparation de la    Haute          Toute l'équipe
démonstration

Les tâches marquées « À attribuer » seront distribuées en fonction des
compétences et de l'arrivée des autres membres.

9. Règles de Pull Request

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
T-06

10. Règle de synchronisation avant développement

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

11. Suivi quotidien

Chaque jour, l'équipe réalise un stand-up de 10 à 15 minutes.

Chaque membre répond :

1. Qu'as-tu fait hier ?

Exemple :

J'ai terminé le modèle Flashcard.

2. Que fais-tu aujourd'hui ?

Je vais travailler sur le modèle Deck.

3. As-tu un blocage ?

Non.

ou :

Oui, problème avec le stockage local.

Tout blocage important doit être remonté rapidement.

12. Règles de communication

prévenir l'équipe en cas d'absence prolongée ;

signaler rapidement les blocages ;

ne pas attendre plusieurs jours avant de demander de l'aide ;

respecter les décisions techniques prises collectivement ;

faire des code reviews constructives ;

éviter les modifications non communiquées dans les parties communes
;

documenter les choix techniques importants.

13. Priorités du projet

L'ordre de priorité est :

1. Fonctionnement du MVP
2. Qualité et stabilité
3. Tests
4. Documentation
5. Interface et finition
6. Bonus Firestore

Le bonus ne doit pas retarder le MVP.

14. Objectif de livraison

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

15. Règle fondamentale du Groupe 34

Nous avançons avec les membres disponibles. Nous n'attendons pas les
membres absents pour commencer.

Les nouveaux membres seront intégrés progressivement et recevront des
tâches adaptées.

L'objectif n'est pas qu'une seule personne fasse tout le projet.

L'objectif est que chaque membre contribue réellement au projet et
progresse pendant le Summer Camp.

16. État actuel

GitHub                     ✅
main protégée              ✅
Projet Flutter initialisé  ✅
develop                    ✅

Architecture               ⏳
Backlog                    ⏳
Répartition définitive     ⏳
Branches feature           ⏳
Développement MVP          ⏳
Tests                      ⏳
Documentation              ⏳
Démo                       ⏳

Prochaine étape recommandée :

Architecture
     ↓
Models
     ↓
Backlog final
     ↓
Branches
     ↓
Développement
