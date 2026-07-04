extends Area3D

# Script partagé par TOUS les obstacles du jeu (arbres, animaux, piétons...).
# On l'attache à la racine (Area3D) de chaque scène d'obstacle, et on règle
# les @export ci-dessous dans l'inspecteur pour chaque type d'obstacle.

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
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if est_mobile:
		position.x += vitesse_deplacement * delta

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
