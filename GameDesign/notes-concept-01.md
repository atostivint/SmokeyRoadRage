# Concept — Smokey Road Rage

## Pitch

Jeu de conduite trash, gameplay façon "Subway Surfers" : plusieurs voies, on va à droite/gauche pour changer de ligne. On traverse une forêt en flammes, on évite obstacles et petits animaux, on écrase les vilains campeurs qui font leur BBQ n'importe où. Il faut spammer espace pour essuyer le pare-brise (visibilité réduite par la fumée/suie).

## Éléments confirmés

- Déplacement latéral par lignes (gauche/droite), pas de contrôle libre.
- Forêt en feu comme décor/contexte de la course.
- Obstacles à éviter : dangereux (dommage si touché).
- Obstacles/cibles à écraser : campeurs faisant du BBQ sauvage (le "méchant" du jeu).
- Petits animaux à éviter (ne pas les écraser).
- Mécanique d'essuie-glace : spam espace pour nettoyer le pare-brise (lié à la fumée/cendres qui s'accumulent, cf. taches sur pare-brise dans notes-brainstorm-01.md).

## Décisions prises

- **Objectif** : arriver au bout de la map (niveau fini, pas un endless runner), si c'est faisable techniquement dans le temps imparti.
- **Pas de système de combo** prévu au vu du temps disponible pour le jam — scoring simple.
- **Smokey l'ours = le personnage que l'on incarne**, c'est lui qui conduit la voiture.
- **Deux catégories d'obstacles, avec traitement différent** :
  - **Animaux de la forêt** (sprites 2D) : pas de mort automatique. Impact = dégâts et/ou pare-brise sali (sang) qu'il faut essuyer avec l'essuie-glace (spam espace). Le joueur peut aussi choisir de continuer à conduire avec les taches de sang sans essuyer (pénalité visuelle/gêne, pas de contrainte dure).
  - **Éléments de décor (arbres, cailloux, etc.)**, modèles 3D : impact = Game Over instantané (collision fatale avec un élément fixe du décor).
- **Pénalité de "bonne conduite" (thème Garofeu)** : rouler sur des piétons "innocents" (ex. petites filles) est pénalisé ; rouler sur les campeurs/incendiaires est récompensé/encouragé. Le jeu punit donc explicitement qui on écrase.
- **UX / intro** : le jeu démarre en vue première personne sur Smokey assis dans la voiture, en train de lire le journal qui parle des feux de forêt. Le journal sert d'interface pour lancer la partie, et réapparaît à la fin (Game Over ou victoire) pour afficher le score sous forme d'articles/gros titres (ex. nombre de personnes écrasées).
- **Multijoueur (optionnel, à valider selon le temps)** : idée de split-screen local ; option de repli plus simple = 4 instances du jeu indépendantes (pas de synchro réseau), classement au meilleur score.
- **Équipe** : 1 personne graphisme, 2 codeurs (dont l'auteur des notes).

## Théma bbqjam2026 — à trancher

- **Smoke King** ("cache sa vraie nature") : twist possible — le jeu a l'air d'un jeu de destruction trash mais révèle un message écolo/pro-forêt ? Le mécanisme du journal (intro/outro) pourrait porter ce twist.
- **Comme à la Maison** (Maison du Jeu Vidéo de Rennes) et **JMJ4EVA** (Jean-Michel Jam) : pas encore abordés.

## Décisions prises (suite)

- **Scoring multi-compteurs** : distance parcourue, nombre de campeurs/incendiaires écrasés (bien), nombre de piétons innocents écrasés (pénalité), timer. Affichage possible en temps réel à l'écran et/ou calculé en résumé de fin de partie — pas encore tranché.
- **Journal intro/outro** : mix d'illustrations dessinées à la main + texte dynamique généré selon les stats de la run (façon gros titres de tabloïd).
- **Barre de vie** : confirmé qu'elle peut mener à un Game Over si elle se vide (pas juste cosmétique). Idée forte : matérialiser la vie via l'**égaliseur de la radio** — son très haut/saturé à pleine vie, égaliseur qui s'affaiblit à mesure que la vie baisse. Diégétique, pas de barre de vie classique à l'écran.
- **Suie/fumée sur le pare-brise** : pas encore confirmé que la fumée de la forêt en feu salisse la vitre, mais si c'est implémenté ce sera la même mécanique d'essuie-glace que pour le sang des animaux.

## Questions ouvertes

1. Compteurs de score en temps réel à l'écran (distance, campeurs écrasés, piétons évités/écrasés, timer) ou uniquement révélés dans le journal à la fin, pour préserver la surprise/le twist ?
2. L'égaliseur radio comme jauge de vie : il faut aussi décider quel son il joue — une radio qui commente les événements (façon radio de GTA) ou juste de la musique dont le volume/qualité se dégrade ?
3. Que se passe-t-il visuellement/gameplay quand la vie (égaliseur) atteint zéro : Game Over immédiat, ou séquence (ex. la voiture cale, dérape) avant le Game Over ?
4. Le score final (distance, campeurs, piétons) donne-t-il un vrai "score" comparable entre joueurs (utile pour le mode 4-instances/leaderboard), ou reste un texte narratif sans classement chiffré ?
5. Durée de run et longueur de map : vu qu'on ne sait pas encore, faut-il fixer une durée cible maintenant (ex. viser 3-5 min) pour dimensionner la taille de la map en fonction du temps de dev restant ?
6. Checkpoints : idem, pas encore décidé — pour un jam avec un temps de dev limité, un simple restart complet au Game Over est probablement le plus rapide à implémenter ; c'est acceptable comme choix par défaut ?
7. Priorisation : vu la taille de l'équipe (1 graphiste, 2 codeurs) et le nombre de features encore ouvertes (splitscreen, checkpoints, fumée sur pare-brise, journal dynamique), quel est le MVP absolu à livrer en premier avant d'attaquer les extras ?
