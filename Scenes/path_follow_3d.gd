extends PathFollow3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var process = create_tween()
	process.tween_property(self, "progress_ratio", 1, 10	)
	

func endGame() -> void:
	print('JEU TERMINE')
