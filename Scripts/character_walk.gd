extends CharacterBody3D

# Contrôleur de marche tout simple, juste pour se balader à pied dans le
# niveau et repérer où placer les obstacles. Pas destiné au gameplay final.

@export var vitesse: float = 5.0
@export var vitesse_rotation: float = 2.0

## Vie de départ (correspond à l'égaliseur radio à terme).
@export var vie_max: int = 100

var vie: int
var score: int = 0

signal vie_changee(vie: int, vie_max: int)
signal score_change(score: int)

func _ready() -> void:
	vie = vie_max

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("turn_left"):
		rotate_y(vitesse_rotation * delta)
	if Input.is_action_pressed("turn_right"):
		rotate_y(-vitesse_rotation * delta)

	velocity = direction.normalized() * vitesse
	move_and_slide()

## Appelée par les obstacles (animaux, piétons) quand ils sont touchés.
func perdre_vie(degats: int) -> void:
	vie = max(vie - degats, 0)
	vie_changee.emit(vie, vie_max)
	print("Vie: ", vie, "/", vie_max)
	if vie <= 0:
		print("Game Over -> plus de vie")

## Appelée par les obstacles quand on gagne ou perd des points.
func ajouter_points(valeur: int) -> void:
	score += valeur
	score_change.emit(score)
	print("Score: ", score)

## Appelée par les obstacles de type DECOR (arbre, pierre...) : mort immédiate.
func mourir_instantanement() -> void:
	vie = 0
	vie_changee.emit(vie, vie_max)
	print("Game Over -> collision avec le décor")
