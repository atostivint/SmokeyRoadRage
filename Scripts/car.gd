extends RigidBody3D

@export var chasing : Node3D

func _physics_process(delta: float) -> void:
	if chasing != null :
		var chasing_distance = chasing.global_position - global_position
		global_position += (chasing_distance *0.3)
	pass
