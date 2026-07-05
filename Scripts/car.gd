extends RigidBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var deer_player: AnimationPlayer = $DeerPlayer
@onready var swipper_player: AnimationPlayer = $SwipperPlayer
@onready var splatter_5: Sprite3D = $Splatter5
@onready var splatter_4: Sprite3D = $Splatter4
@onready var splatter_3: Sprite3D = $Splatter3
@onready var splatter_2: Sprite3D = $Splatter2
@onready var splatter_1: Sprite3D = $Splatter1

## Vie de départ (correspond à l'égaliseur radio à terme).
@export var vie_max: int = 100

var vie: int
var score: int = 0

signal vie_changee(vie: int, vie_max: int)
signal score_change(score: int)

## Vitesse de la voiture en mètres/seconde
@export var vitesse : float = 15.0

## Durée (en secondes) pour glisser doucement d'une voie à l'autre au lieu de
## sauter instantanément dessus (ce saut brutal secouait la caméra).
@export var duree_changement_voie : float = 0.4

## Vitesse à laquelle la voiture (et donc la caméra, attachée dessus) tourne
## pour s'aligner sur sa direction. Plus la valeur est basse, plus la rotation
## est douce (moins de mal des transports lors d'un changement de voie).
@export var vitesse_rotation : float = 6.0

## Le RoadLaneAgent : c'est lui qui sait calculer la prochaine position
## le long de la route (voie actuelle + voies suivantes connectées).
## Il vit dans la scène du niveau (à côté de la route), pas dans la voiture :
## à assigner à la main dans l'inspecteur en glissant le nœud RoadLaneAgent.
@export var road_lane_agent : RoadLaneAgent

## +1 pour avancer via lane_next, -1 via lane_prior.
## Certains RoadPoint de départ sont posés à l'envers de la voie (le "next"
## est vide côté départ) : on détecte ça une fois au démarrage.
var sens_avancee := 1.0

## Écart restant entre l'ancienne position et la nouvelle voie après un
## changement de voie ; on le résorbe petit à petit sur duree_changement_voie
## au lieu de téléporter la voiture d'un coup.
var decalage_transition := Vector3.ZERO
var temps_transition := 0.0

## Position le long de la route (sans le glissement latéral d'un changement
## de voie) au tour précédent, pour calculer une direction "propre" qui ne
## tourne pas brusquement pendant une transition de voie.
var derniere_position_route : Vector3
var position_route_initialisee := false

func _ready() -> void:
	vie = vie_max
	splatter_1.modulate.a = 0
	splatter_2.modulate.a = 0
	splatter_3.modulate.a = 0
	splatter_4.modulate.a = 0
	splatter_5.modulate.a = 0

	# Le RoadLaneAgent vit dans la scène du niveau, pas dans la voiture : le
	# script du plugin devine "qui il pilote" via son parent, ce qui pointerait
	# ici vers la route et non la voiture. On corrige la référence à la main.
	road_lane_agent.actor = self

	# Au démarrage, on accroche la voiture à la voie de route la plus proche.
	road_lane_agent.assign_nearest_lane()
	if road_lane_agent.current_lane == null:
		pass
	var lane = road_lane_agent.current_lane
	if lane and lane.lane_next == NodePath("") and lane.lane_prior != NodePath(""):
		sens_avancee = -1.0

## Appelée par les obstacles (animaux, piétons) quand ils sont touchés.
func perdre_vie(degats: int) -> void:
	vie = max(vie - degats, 0)
	vie_changee.emit(vie, vie_max)
	print("Vie: ", vie, "/", vie_max)
	deer_player.play('DeerSlide')
	if vie <= 0:
		print("Game Over -> plus de vie")

func ajouter_sang() -> void:
	for x in range(5) :
		if splatter_1.modulate.a < 1:
			splatter_1.modulate.a += 0.5
		elif splatter_2.modulate.a < 1:
			splatter_2.modulate.a += 0.5
		elif splatter_3.modulate.a < 1:
			splatter_3.modulate.a += 0.5
		elif splatter_4.modulate.a < 1:
			splatter_4.modulate.a += 0.5
		elif splatter_5.modulate.a < 1:
			splatter_5.modulate.a += 0.5
			
func retirer_sang() -> void:
	if splatter_5.modulate.a > 0:
		splatter_5.modulate.a -= 0.5
	elif splatter_4.modulate.a > 0:
		splatter_4.modulate.a -= 0.5
	elif splatter_3.modulate.a > 0:
		splatter_3.modulate.a -= 0.5
	elif splatter_2.modulate.a > 0:
		splatter_2.modulate.a -= 0.5
	elif splatter_1.modulate.a > 0:
		splatter_1.modulate.a -= 0.5

## Appelée par les obstacles quand on gagne ou perd des points.
func ajouter_points(valeur: int) -> void:
	score += valeur
	score_change.emit(score)
	ajouter_sang()
	print("Score: ", score)

## Appelée par les obstacles de type DECOR (arbre, pierre...) : mort immédiate.
func mourir_instantanement() -> void:
	vie = 0
	vie_changee.emit(vie, vie_max)
	print("Game Over -> collision avec le décor")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(road_lane_agent.current_lane):
		return

	# Changement de voie : "just_pressed" = déclenché une seule fois par appui,
	# pas à chaque frame tant que la touche reste enfoncée.
	if Input.is_action_just_pressed("turn_left"):
		_demarrer_changement_voie(road_lane_agent.change_lane(-1))
		animation_player.play("GoingLeft")
	elif Input.is_action_just_pressed("turn_right"):
		_demarrer_changement_voie(road_lane_agent.change_lane(1))
		animation_player.play("GoingRight")
	elif Input.is_action_just_released("turn_right") or Input.is_action_just_released("turn_left"):
		animation_player.play('GoingForward')
	
	if Input.is_action_just_pressed("Swipping"):
		match randi_range(1, 4):
			1:
				swipper_player.play("Swip1")
			2:
				swipper_player.play("Swip2")
			3:
				swipper_player.play("Swip3")
			4:
				swipper_player.play("Swip4")
		retirer_sang()

	# Demande au RoadLaneAgent la position "vitesse * delta" mètres plus loin
	# sur la route ; il gère tout seul le passage à la voie suivante connectée.
	var prochaine_position = road_lane_agent.move_along_lane(sens_avancee * vitesse * delta)

	# Résorbe petit à petit l'écart laissé par un changement de voie récent,
	# pour glisser au lieu de sauter d'un coup sur la nouvelle voie.
	if temps_transition < duree_changement_voie:
		temps_transition += delta
		var t = clamp(temps_transition / duree_changement_voie, 0.0, 1.0)
		decalage_transition = decalage_transition.lerp(Vector3.ZERO, t)
	else:
		decalage_transition = Vector3.ZERO

	# La direction de la voiture ne se base que sur l'avancée le long de la
	# route (prochaine_position d'une frame à l'autre), jamais sur le
	# glissement latéral du changement de voie (decalage_transition) : sinon
	# la voiture pivotait fortement sur le côté pendant la transition, ce qui
	# donnait le mal des transports puisque la caméra est attachée dessus.
	if not position_route_initialisee:
		derniere_position_route = prochaine_position
		position_route_initialisee = true
	var direction_route = prochaine_position - derniere_position_route
	derniere_position_route = prochaine_position

	global_position = prochaine_position + decalage_transition

	# Oriente la voiture progressivement vers la direction de la route au lieu
	# de la faire pivoter instantanément (look_at) : la rotation "rattrape"
	# la direction cible sur plusieurs frames, ce qui est beaucoup plus doux.
	if direction_route.length() > 0.01:
		var basis_actuel = global_transform.basis
		var basis_cible = Transform3D().looking_at(direction_route.normalized(), Vector3.UP).basis
		var poids = clamp(vitesse_rotation * delta, 0.0, 1.0)
		global_transform.basis = basis_actuel.slerp(basis_cible, poids).orthonormalized()


func _demarrer_changement_voie(resultat_changement: int) -> void:
	if resultat_changement != OK:
		return
	# On vient de basculer sur la nouvelle voie : on calcule l'écart entre
	# l'endroit où on est réellement et le point équivalent sur cette nouvelle
	# voie, pour le résorber en douceur plutôt que de sauter dessus d'un coup.
	var point_sur_nouvelle_voie = road_lane_agent.move_along_lane(0.0)
	decalage_transition = global_position - point_sur_nouvelle_voie
	temps_transition = 0.0


func _on_swipper_player_animation_finished(anim_name: StringName) -> void:
	swipper_player.play("RESET")
