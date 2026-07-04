@tool
extends Area3D

# Script partagé par TOUS les obstacles du jeu (arbres, animaux, piétons...).
# On l'attache à la racine (Area3D) de chaque scène d'obstacle, et on règle
# les @export ci-dessous dans l'inspecteur pour chaque type d'obstacle.
#
# "@tool" en haut du fichier veut dire que ce script tourne aussi dans
# l'éditeur (pas seulement pendant que le jeu est lancé). C'est ce qui
# permet au bouton "Coller à la voie" ci-dessous de fonctionner directement
# dans l'inspecteur, sans avoir à lancer le jeu.

## Nom du groupe Godot dans lequel le RoadManager range ses voies IA
## (réglage "Ai Lane Group" sur le nœud RoadManager de la scène de niveau).
@export var groupe_voies_ia: String = "ai_road_lanes"

## Bouton dans l'inspecteur : recale cet obstacle sur le point le plus
## proche de la voie la plus proche du groupe ci-dessus.
@export_tool_button("Coller à la voie la plus proche") var coller_a_la_voie_bouton: Callable = Callable(self, "coller_a_la_voie")

enum Categorie {
	DECOR,            # arbres, cailloux... impact = Game Over instantané
	ANIMAL_INNOCENT,  # innocents, impact = dégâts + sang + pénalité de score
	PIETON_CIBLE,     # campeurs/incendiaires, impact = récompense (score+)
}

@export var categorie: Categorie = Categorie.DECOR

## Si coché, l'obstacle se déplace (ex: un animal qui traverse la route).
## Si décoché, il reste fixe à sa position dans la scène.
@export var est_mobile: bool = false

## Vitesse de déplacement latéral, utilisée seulement si "est_mobile" est coché.
@export var vitesse_deplacement: float = 2.0

## Dégâts infligés à la voiture (ignoré pour la catégorie DECOR, qui tue direct).
@export var degats: int = 10

## Points gagnés ou perdus quand on écrase cet obstacle (peut être négatif).
@export var points: int = 0

signal touche_par_voiture(obstacle: Node)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if est_mobile:
		position.x += vitesse_deplacement * delta

## Cherche, parmi toutes les voies du groupe "groupe_voies_ia", le point le
## plus proche de cet obstacle, puis déplace l'obstacle sur ce point.
## Une "voie" (RoadLane, fournie par l'addon road-generator) est une courbe
## (Path3D) qui suit la route même si elle tourne : projeter l'obstacle
## dessus garantit qu'il reste bien aligné dans sa voie de circulation.
func coller_a_la_voie() -> void:
	var voies := get_tree().get_nodes_in_group(groupe_voies_ia)
	if voies.is_empty():
		push_warning("Aucune voie trouvée dans le groupe '%s'." % groupe_voies_ia)
		return

	var meilleure_position := global_position
	var meilleure_distance := INF

	for voie in voies:
		if not voie is Path3D:
			continue
		var position_locale: Vector3 = voie.to_local(global_position)
		var point_local: Vector3 = voie.curve.get_closest_point(position_locale)
		var point_global: Vector3 = voie.to_global(point_local)
		var distance := global_position.distance_to(point_global)
		if distance < meilleure_distance:
			meilleure_distance = distance
			meilleure_position = point_global

	global_position = meilleure_position

func _on_body_entered(body: Node) -> void:
	if body.name != "Car":
		return
	touche_par_voiture.emit(self)
	match categorie:
		Categorie.DECOR:
			body.mourir_instantanement()
		Categorie.ANIMAL_INNOCENT:
			body.perdre_vie(degats)
			body.ajouter_points(points)
		Categorie.PIETON_CIBLE:
			body.ajouter_points(points)
