extends RigidBody3D

@export var chasing : Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if chasing != null :
		var chasing_distance = chasing.global_position - global_position
		global_position += (chasing_distance *0.3)
	pass

func _process(delta):
	if Input.is_action_just_pressed("turn_right"):
		animation_player.play("GoingRight")
	elif Input.is_action_just_pressed("turn_left"):
		animation_player.play("GoingLeft")
	elif Input.is_action_just_released("turn_left") or Input.is_action_just_released("turn_right"):
		animation_player.play("GoingForward")
