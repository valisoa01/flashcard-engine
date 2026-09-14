# FlashCard Engine — Guide de présentation

Document d'accompagnement pour la présentation du **16 septembre 2026**.

Ce document explique le projet en détail afin que toute personne de
l'équipe (même sans compétences en code) puisse le présenter, répondre
aux questions et animer la démonstration. Il complète le `README.md` qui
reste le document technique de référence.

---

## 1. Vue d'ensemble

**Quoi ?** Une application mobile Flutter de **cartes mémoires** utilisée
pour réviser ses connaissances avec un système de **répétition espacée**.

**Pour qui ?** Toute personne qui veut apprendre : étudiants, apprentissage
de langues, révisions d'examens, vocabulaire technique, etc.

**Comment ça marche en une phrase ?** On crée des paquets de cartes
(« decks »), chaque carte contient une question et sa réponse, et
l'application planifie automatiquement le meilleur moment pour vous faire
réviser chaque carte.

**Nom du projet :** FlashCard Engine
**Créé pour :** FlutterFire Summer Camp 2026
**Période :** 2 septembre — 16 septembre 2026

---

## 2. Le problème que l'on résout

Réviser, c'est efficace, mais seulement si on le fait **au bon moment**.
Sans système, on a tendance à :

- réviser tout au dernier moment avant un examen ;
- oublier ce qu'on a appris il y a une semaine ;
- perdre du temps sur des cartes que l'on connaît déjà très bien.

La science de la mémoire (courbe de l'oubli) montre qu'on retient mieux
si on révise **juste avant d'oublier**, avec des intervalles qui
augmentent au fil du temps.

C'est exactement ce que fait l'application : elle décide, pour chaque
carte, **quand la re-proposer** en fonction de la difficulté ressentie par
l'utilisateur.

---

## 3. Fonctionnalités principales

### Gestion des decks (paquets de cartes)
- Créer un deck (ex. « Anglais », « Histoire », « Anatomie »).
- Consulter la liste des decks sur l'écran d'accueil.
- Supprimer un deck.

### Gestion des flashcards (cartes)
- Créer une carte avec une **question** et une **réponse**.
- Voir la question, retourner la carte pour voir la réponse.
- Modifier ou supprimer une carte.
- Chaque carte est rattachée à un deck.

### Révision intelligente (Study)
- Démarre une session avec uniquement les cartes **à revoir** (celles dont
  la date de révision est arrivée).
- Affiche la question, puis la réponse après un simple appui.
- L'utilisateur évalue sa propre réussite sur 4 niveaux :
  **Encore, Difficile, Bien, Facile**.
- L'application met à jour automatiquement la carte et planifie la
  prochaine révision.
- Un récapitulatif s'affiche en fin de session.

### Spaced Repetition (le cœur du projet)
Algorithme inspiré de la méthode **SM-2** (efficace et éprouvée,
utilisée par Anki et SuperMemo), implémenté **en Dart pur** (sans
dépendance à Flutter) afin d'être indépendant de l'interface.

### Stockage local
Les données sont enregistrées durablement sur l'appareil avec la base de
données **Hive**. On peut fermer l'application et retrouver ses decks et
sa progression.

### Import / Export JSON
- **Export** : toute la base est transformée en un fichier JSON lisible.
- **Import** : on recolle ce JSON pour restaurer ou transférer ses données.

### Synchronisation Firestore (bonus)
Optionnel : possibilité de **pousser** les données vers le cloud
Cloud Firestore ou de les **récupérer** depuis un autre appareil.

---

## 4. Parcours utilisateur (scénario de la démonstration)

1. **Ouverture** : l'écran d'accueil « Mes decks » affiche la liste.
   Au départ, elle est vide → « Aucun deck. Créez-en un ! ».
2. **Création d'un deck** : bouton `+`, on saisit le titre
   (ex. « Anglais ») et une description, on valide. Le deck apparaît.
3. **Ouverture du deck** : on voit le nombre de cartes et le bouton
   « Réviser ».
4. **Création de cartes** : bouton `+`, question « Bonjour ? »,
   réponse « Hello », on valide. La carte apparaît dans la liste.
5. **Révision** : toucher « Réviser ». La carte à revoir s'affiche.
6. **Découverte** : on touche « Voir la réponse », la réponse apparaît.
7. **Évaluation** : on choisit « Bien » par exemple. L'application calcule
   la prochaine révision (ex. dans 1 jour).
8. **Fin de session** : « Session terminée ! » avec le détail des
   réponses.
9. **Bonus démo** (optionnel) : exporter le JSON, puis le réimporter ;
   ou utiliser l'icône nuage pour synchroniser avec Firestore.

---

## 5. Architecture technique (à comprendre pour bien présenter)

```
lib/
  models/          Les 3 objets métier : Deck, Flashcard, Review
  repositories/    Accès aux données (interfaces + implémentation Hive)
  screens/         Les 4 écrans : Home, Deck, Study, Détail carte
  services/        La logique : Spaced Repetition, JSON, Firestore
  app.dart         Le point d'entrée de l'application
test/
  ...              34 tests (unitaires + widgets)
```

Trois couches distinctes :

1. **Modèles** : la structure des données.
2. **Services** : la logique pure (l'algorithme).
3. **Repositories / Écrans** : stockage et interface.

Ce découpage permet de tester la logique indépendamment de l'interface
et de changer de base de données sans toucher aux écrans.

---

## 6. Les modèles de données

### Deck (un paquet de cartes)
- `id` : identifiant unique
- `title` : le titre (ex. « Anglais »)
- `description` : une description libre
- `createdAt` / `updatedAt` : dates de création et modification

### Flashcard (une carte)
- `id`, `deckId` : identifiants
- `question`, `answer` : le contenu
- `repetitions` : nombre de fois réussie (progression)
- `interval` : l'intervalle actuel en jours avant la prochaine révision
- `easeFactor` : le « facteur de facilité » (la vitesse de progression)
- `nextReview` : la date de la prochaine révision
- `createdAt` / `updatedAt`

### Review (une évaluation)
Enregistre chaque réponse : `quality` (Encore / Difficile / Bien /
Facile), l'ancien et le nouvel intervalle, l'ancien et le nouveau facteur
de facilité, et la date de la révision. C'est l'historique de l'utilisation.

---

## 7. L'algorithme Spaced Repetition (à savoir expliquer simplement)

### Le principe
Chaque carte possède deux « boutons » invisibles que l'algorithme ajuste :

- **l'intervalle** : dans combien de jours la carte reviendra ;
- **le facteur de facilité** : la « vitesse » de progression de la carte.

Plus l'utilisateur répond bien, plus la carte s'éloigne et plus le facteur
augmente. S'il répond mal, la carte revient vite et tout est recalculé.

### Les règles concrètes (SM-2 adapté)
- **Nouvelle carte** : facteur de facilité initial = **2,5**.
- **Réponse « Encore »** : la carte **recommence à zéro** (progression à 0)
  et revient **le lendemain**.
- **Réponse réussie** (Difficile / Bien / Facile) : la progression
  augmente de 1, puis l'intervalle suit une grille :
  - 1er jour, puis 6 jours, puis `intervalle × facteur` ;
  - « Facile » est plus rapide que « Bien », « Difficile » plus lent.
- **Date de prochaine révision** = date de révision + intervalle.

### Exemple concret
Une carte répondue « Bien » aujourd'hui revient demain ; à nouveau
« Bien », elle revient dans 6 jours ; puis dans 15 jours, puis 37 jours...
La carte s'espace naturellement tant qu'elle est connue. Si un jour la
réponse est « Encore », tout repart de demain.

### Pourquoi c'est un point fort à mettre en avant
- Algorithme **indépendant de Flutter** (Dart pur) : réutilisable et
  testable.
- **11 tests unitaires** dédiés garantissent les calculs.
- Le choix des modèles (`Review`...) permet de tracer l'historique et
  d'intégrer facilement d'autres algorithmes plus tard.

---

## 8. Base de données locale (Hive)

Les repositories implémentent des **interfaces** (`DeckRepository`,
`FlashcardRepository`) avec l'implémentation **Hive** en local :

- rapide, embarquée, persistante ;
- chaque modèle sait se convertir en JSON (`toJson` / `fromJson`), ce qui
  sert aussi à l'import/export.

L'interface permet de remplacer Hive par une autre base sans changer les
écrans.

---

## 9. Import / Export JSON

- **Export** : tous les decks et toutes les cartes sont regroupés dans un
  objet JSON structuré (`version`, `exportedAt`, `decks`, `flashcards`).
  Le texte est affiché pour être copié (icône de téléchargement sur
  l'écran d'accueil).
- **Import** : on colle le JSON, l'application le valide (erreurs claires
  si le contenu est invalide) puis restaure les données.

Utile pour : sauvegarde, transfert entre appareils, contribution d'un
jeu de données de démonstration.

---

## 10. Synchronisation Firestore (bonus)

Icône **nuage** sur l'écran d'accueil :

- **Pousser** : envoie tous les decks et cartes locaux vers Cloud
  Firestore.
- **Récupérer** : télécharge les données depuis Firestore vers l'appareil.

C'est **optionnel** : si Firebase n'est pas configuré (ex. sur un poste de
travail), l'application fonctionne normalement et la synchro reste
désactivée proprement.

---

## 11. Qualité et tests

- **34 tests** au total, tous verts (`flutter test`) :
  - 11 tests pour l'algorithme Spaced Repetition (intervalles, facteur,
    dates, cas « Encore »...) ;
  - 6 tests pour le service JSON (export/import, validation, cas d'erreur) ;
  - des tests de widgets (écrans Home, Deck, Study) ;
  - un test de **parcours complet** : créer un deck → créer une carte →
    réviser → évaluer → vérifier que la carte est mise à jour.
- **Analyse statique** : `dart analyze` sans erreur ni avertissement.
- **Chaque branche de fonctionnalité** a été fusionnée après vérification.

---

## 12. Organisation du travail et outils

### Git / GitHub
- **main** : version stable et livrable (protégée).
- **develop** : zone d'intégration des fonctionnalités.
- **feature/*`** : une branche par fonctionnalité.

### Répartition
- Développement réalisé seul par Valisoa (l'équipe a quitté le projet
  le 12 septembre), avec une organisation par modules conservée :
  architecture, modèles, base de données, écrans, Spaced Repetition,
  JSON, intégration, documentation.

### Suivi
- `task.md` : répartition des tâches, statuts et planning (au niveau 1
  du dépôt).

---

## 13. Points forts à mettre en avant

1. **MVP complet et fonctionnel** : on peut réellement créer des decks,
   des cartes et réviser de bout en bout.
2. **Algorithme de répétition espacée** éprouvé (SM-2) et implémenté en
   **Dart pur**, entièrement testé.
3. **Persistance locale** : aucune perte de données à la fermeture.
4. **Import / Export JSON** opérationnels.
5. **Bonus Firestore** présenté comme valeur ajoutée.
6. **Qualité** : 34 tests verts, analyse sans erreur.
7. **Bonne architecture** : séparation modèles / services / écrans,
   interfaces pour les repositories (facile à faire évoluer).
8. **Travail organisé en solo** malgré le départ de l'équipe : respect
   du planning, de la branche développée proprement, du processus.

---

## 14. Questions fréquentes (à préparer)

**Qu'est-ce que la répétition espacée ?**
Une méthode de révision qui planifie les révisions à des intervalles qui
augmentent quand on réussit, pour ancrer la mémoire durablement.

**Pourquoi Hive plutôt qu'une autre base ?**
Simple à intégrer, rapide, persistante, et cachée derrière une interface
qui permet de la remplacer.

**L'algorithme dépend-il de Flutter ?**
Non : il est écrit en Dart pur, sans aucun import Flutter, pour être
indépendant de l'interface et facilement testé.

**Que se passe-t-il si on répond « Encore » ?**
La carte revient le lendemain et sa progression repart de zéro, mais son
facteur de facilité diminue pour s'adapter à sa difficulté réelle.

**La synchronisation Firestore est-elle obligatoire ?**
Non, c'est un bonus optionnel. L'application fonctionne parfaitement en
local sans Firebase.

**Peut-on transférer ses données ?**
Oui : l'export JSON permet de sauvegarder, et l'import permet de restaurer
ou déplacer les données.

---

## 15. Déroulement conseillé de la présentation (5-10 minutes)

1. **Intro (30 s)** : « FlashCard Engine : une application de cartes
   mémoire avec répétition espacée pour réviser intelligemment. »
2. **3 problèmes du quotidien** (1 min) : on oublie, on révise au
   mauvais moment, on perd du temps → grâce à la science de la mémoire.
3. **Démo en direct** (3-5 min) : créer un deck → ajouter des cartes →
   réviser → évaluer → montrer le récapitulatif.
4. **Bonus si le temps le permet** (1 min) : export/import JSON, puis
   synchronisation Firestore.
5. **Écran de points forts** (1 min) : les 8 points forts de la
   section 13.
6. **Conclusion** (30 s) : « Le MVP est terminé, testé (34 tests verts)
   et prêt à être utilisé. »