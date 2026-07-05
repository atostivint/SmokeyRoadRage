extends Sprite3D

## Affiche en 3D le rendu du SubViewport "EcranViewport" (frère de ce nœud),
## qui contient le contenu 2D à projeter sur l'écran de l'autoradio.
@onready var viewport: SubViewport = $"../EcranViewport"

func _ready() -> void:
	texture = viewport.get_texture()
