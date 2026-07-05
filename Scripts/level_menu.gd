extends Control

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# bruit de journal
	audio_stream_player.stream = preload("uid://dychlqc3dfyck")
	audio_stream_player.volume_db = 1
	audio_stream_player.play()

func play_music() -> void:
	audio_stream_player.stream = preload("uid://ba3wp5p4rmq75")
	audio_stream_player.volume_db = 0.8
	audio_stream_player.play()

## Bouton A de la manette = lancer la partie, bouton B = quitter le jeu.
## On regarde directement l'événement manette (pas les actions ui_accept/ui_cancel)
## pour ne pas dépendre de leur configuration par défaut dans Godot.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			Score.score_deer = 0
			Score.score_smoker = 0
			get_tree().change_scene_to_file("res://Scenes/level_highway.tscn")
		elif event.button_index == JOY_BUTTON_B:
			get_tree().quit()
