extends Control

@onready var smoker_score: Label = $TextureRect/SmokerScore
@onready var deer_score: Label = $TextureRect/DeerScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	smoker_score.text = str(Score.score_smoker)
	deer_score.text = str(Score.score_deer)
	
