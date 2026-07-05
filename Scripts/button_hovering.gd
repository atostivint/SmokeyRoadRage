extends Button

@export var regular_icon : Texture2D
@export var hover_icon : Texture2D


func _on_mouse_entered() -> void:
	icon = hover_icon


func _on_mouse_exited() -> void:
	icon = regular_icon

func quit_game() -> void:
	get_tree().quit()

func play() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_highway.tscn")
