# gen_obstacles_highway.py — c'est quoi ?

Un petit script Python (pas du GDScript, donc pas ouvert par Godot) qui place
automatiquement tous les obstacles (rochers, souches, biches, campeurs) le
long de la route du niveau `level_highway.tscn`, avec un espacement irrégulier
et une répartition équilibrée entre les 4 voies.

Il ne fait qu'une chose : réécrire directement le fichier
`level_highway.tscn` (du texte, pas un format binaire) pour y injecter/
remplacer les nœuds sous `ObstacleGroup`. Il ne touche à rien d'autre dans la
scène (route, voiture, environnement).

## Comment le relancer

1. Ferme le niveau dans Godot si tu l'as ouvert en édition (ou au moins ne
   sauvegarde rien par-dessus pendant que le script tourne).
2. Dans un terminal, à la racine du projet :

   ```
   python3 Scenes/gen_obstacles_highway.py
   ```

3. Rouvre / recharge `level_highway.tscn` dans Godot (clic droit sur l'onglet
   de la scène → "Reload Saved Scene", ou ferme puis rouvre le fichier) pour
   voir le résultat — le script a écrit directement sur le disque.

Aucune dépendance à installer : uniquement les modules standards de Python
(`re`, `random`, `math`, `pathlib`).

## Ce que tu peux régler toi-même

Ouvre `gen_obstacles_highway.py`, tout est en haut du fichier sous forme de
constantes en MAJUSCULES :

- `MIN_SPACING` / `MAX_SPACING` (16.0 / 32.0) — distance minimale/maximale en
  mètres entre deux obstacles le long de la route. Le script tire un nombre
  aléatoire dans cette fourchette à chaque fois.
- `START_SKIP` (60.0) — longueur en mètres laissée libre juste après le
  point de départ de la voiture, pour ne pas spawner un obstacle sous son nez.
- `LANE_CENTERS` (`[-6.0, -2.0, 2.0, 6.0]`) — position de chacune des 4 voies
  par rapport au centre de la route. Ne change ça que si la route change de
  largeur ou de nombre de voies (voir plus bas).
- Les proportions 50 % obstacles décor / 30 % biches / 20 % campeurs sont
  calculées un peu plus bas dans le fichier (`n_obstacles`, `n_biches`,
  `n_bystanders`) si jamais tu veux changer ces ratios.
- `random.seed(42)` en tout début de fichier : change ce nombre (ou
  supprime la ligne) si tu veux un tirage différent à chaque exécution
  plutôt que toujours le même résultat.

## Pourquoi ça place les obstacles pile sur la route (et pas à côté)

Le niveau utilise l'addon "road-generator" : la route n'est pas une ligne
droite entre les points `RP_001`, `RP_002`, etc, c'est une courbe de Bézier
calculée à partir de l'orientation et de la "magnitude" (`next_mag` /
`prior_mag`) de chaque point. Le script recalcule cette même courbe pour
savoir exactement où passe la route à chaque mètre, puis choisit une des 4
voies (`LANE_CENTERS`) perpendiculairement à cette courbe. C'est ce qui
évite d'avoir des obstacles qui débordent dans le décor sur les virages
serrés.

Si un jour la route est refaite avec un nombre de voies différent (le champ
`traffic_dir` dans `level_highway.tscn`) ou une largeur de voie différente
(`lane_width`, 4 mètres par défaut), il faudra mettre à jour `LANE_CENTERS`
en conséquence.

## Limites à connaître

- Le script est écrit pour `level_highway.tscn` spécifiquement (chemin en
  dur vers ce fichier). Pour un autre niveau, il faudrait dupliquer/adapter
  le script.
- Il repère les points de route via leur nom `RP_001`, `RP_002`, ... — si tu
  renommes ou réordonnes ces points dans l'éditeur Godot, relance le script
  après pour resynchroniser les obstacles.
- Relancer le script est sans risque : il supprime d'abord tout ce qui est
  sous `ObstacleGroup` (et d'éventuels restes d'anciens essais) avant de
  regénérer, donc pas de doublons qui s'accumulent.
