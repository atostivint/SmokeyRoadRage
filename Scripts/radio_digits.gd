extends Node3D

# Affiche le nombre de campeurs/incendiaires écrasés (catégorie PIETON_CIBLE)
# sous forme de chiffres façon "écran digital", dessinés avec la police
# bitmap Visuals/Images/font.png (10 chiffres de 32x32 px, dans l'ordre
# 1,2,3,4,5,6,7,8,9,0).
#
# Fonctionnement : un SubViewport (mini-écran invisible en 2D) contient une
# rangée de TextureRect, un par chiffre affiché. Le Sprite3D "Ecran" (frère
# de ce nœud) montre simplement le rendu de ce SubViewport, collé sur
# l'autoradio en 3D. Ça permet de dessiner du texte "2D" classique tout en
# le voyant posé sur un objet du monde 3D.

## Nombre de chiffres affichés à l'écran (complété avec des zéros de tête).
@export var nombre_chiffres: int = 2

## Nom du groupe Godot dans lequel range les obstacles du niveau (le nœud
## "ObstacleGroup" de level_highway.tscn doit être ajouté à ce groupe).
## On utilise un groupe plutôt qu'un NodePath direct car "Radio" est niché
## dans la scène "Car" instanciée dans le niveau : un NodePath vers un autre
## nœud du niveau ne peut pas être sauvegardé sans activer "Enfants
## modifiables" sur l'instance, ce qui est fragile. Un groupe fonctionne
## depuis n'importe quelle scène sans ce problème.
@export var groupe_obstacles: String = "obstacles"

## La feuille de police (10 chiffres de 32x32 px, dans l'ordre 1-9 puis 0).
@export var feuille_police: Texture2D = preload("res://Visuals/Images/font.png")

const TAILLE_GLYPHE := 32
# Position de chaque chiffre (0-9) dans la feuille de police, qui est
# rangée dans l'ordre "1,2,3,4,5,6,7,8,9,0".
const ORDRE_GLYPHES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

var nombre_touches: int = 0
var atlas_par_chiffre: Array[AtlasTexture] = []

@onready var viewport: SubViewport = $EcranViewport
@onready var conteneur_chiffres: HBoxContainer = $EcranViewport/Chiffres
@onready var ecran_sprite: Sprite3D = $Ecran

func _ready() -> void:
	_construire_atlas()
	_creer_cases_chiffres()
	_mettre_a_jour_affichage()

	ecran_sprite.texture = viewport.get_texture()

	# Différé d'une frame : au moment où "Radio" est prêt, les obstacles du
	# niveau (nœuds frères plus loin dans l'arborescence) n'ont pas forcément
	# encore eu leur propre _ready() exécuté, donc pas encore rejoint le
	# groupe "obstacles". call_deferred attend que toute la scène soit prête.
	call_deferred("_connecter_obstacles")

func _connecter_obstacles() -> void:
	var obstacles := get_tree().get_nodes_in_group(groupe_obstacles)
	if obstacles.is_empty():
		push_warning("RadioDigits: aucun obstacle dans le groupe '%s', vérifie qu'ObstacleGroup y est bien ajouté." % groupe_obstacles)
		return

	var nb_connectes := 0
	for enfant in obstacles:
		if "categorie" in enfant and enfant.categorie == enfant.Categorie.PIETON_CIBLE:
			enfant.touche_par_voiture.connect(_on_ennemi_touche)
			nb_connectes += 1

func _on_ennemi_touche(obstacle: Node) -> void:
	nombre_touches += 1
	_mettre_a_jour_affichage()

func _construire_atlas() -> void:
	atlas_par_chiffre.resize(10)
	for chiffre in range(10):
		var position_dans_police := ORDRE_GLYPHES.find(chiffre)
		var atlas := AtlasTexture.new()
		atlas.atlas = feuille_police
		atlas.region = Rect2(position_dans_police * TAILLE_GLYPHE, 0, TAILLE_GLYPHE, TAILLE_GLYPHE)
		atlas_par_chiffre[chiffre] = atlas

func _creer_cases_chiffres() -> void:
	for i in range(nombre_chiffres):
		var case := TextureRect.new()
		case.custom_minimum_size = Vector2(TAILLE_GLYPHE, TAILLE_GLYPHE)
		case.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		case.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		conteneur_chiffres.add_child(case)

func _mettre_a_jour_affichage() -> void:
	var texte := str(nombre_touches).pad_zeros(nombre_chiffres)
	if texte.length() > nombre_chiffres:
		texte = texte.substr(texte.length() - nombre_chiffres)

	for i in range(nombre_chiffres):
		var chiffre := int(texte[i])
		conteneur_chiffres.get_child(i).texture = atlas_par_chiffre[chiffre]

	print("[RadioDigits] Écran rafraîchi : affichage = '", texte, "' (nombre_touches = ", nombre_touches, ")")
