extends PathFollow3D

@onready var way_one: Path3D = %WayOne
@onready var way_two: Path3D = %WayTwo
@onready var way_three: Path3D = %WayThree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var process = create_tween()
	process.tween_property(self, "progress_ratio", 1, 10)
	process.finished.connect(endGame)

func _process(delta):
	if Input.is_action_just_pressed("turn_right"):
		if get_parent() == way_one:
			reparent(way_two)
		elif get_parent() == way_two:
			reparent(way_three)
	if Input.is_action_just_pressed("turn_left"):
		if get_parent() == way_two:
			reparent(way_one)
		elif get_parent() == way_three:
			reparent(way_two)

func endGame() -> void:
	print('JEU TERMINE')
