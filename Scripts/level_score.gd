extends Control

@onready var smoker_score: Label = $TextureRect/SmokerScore
@onready var deer_score: Label = $TextureRect/DeerScore
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	smoker_score.text = str(Score.score_smoker)
	deer_score.text = str(Score.score_deer)
	# bruit de journal
	audio_stream_player.stream = preload("uid://dychlqc3dfyck")
	audio_stream_player.volume_db = 1
	audio_stream_player.play()

func play_music() -> void:
	audio_stream_player.stream = preload("uid://ba3wp5p4rmq75")
	audio_stream_player.volume_db = 0.8
	audio_stream_player.play()
