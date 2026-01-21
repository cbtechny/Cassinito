class_name Card
extends Control

@onready var face_sprite : Sprite2D = $txtr_container/card_face
@onready var back_sprite : AnimatedSprite2D = $txtr_container/BackCardSprite
@onready var shadow : Sprite2D = $txtr_container/shadow
@onready var ace_label : Label = $AceConfig/ace_hint_label

var card_data : CardData
var face_up : bool = true

func _ready() -> void:
	if card_data:
		_configure_sprites()
	update_visuals()

func setup(data : CardData) -> void:
	card_data = data
	if is_node_ready():
		_configure_sprites()
		update_visuals()

func _configure_sprites() -> void:
	if card_data.texture_map_region != Rect2(0,0,0,0):
		face_sprite.region_enabled = true
		face_sprite.region_rect = card_data.texture_map_region

func set_face_up(is_face_up : bool) -> void:
	face_up = is_face_up
	update_visuals()

func update_visuals() -> void:
	if not is_node_ready():
		return

	if face_up:
		face_sprite.visible = true
		back_sprite.visible = false
	else:
		face_sprite.visible = false
		back_sprite.visible = true

func highlight(active : bool) -> void:
	if active:
		modulate = Color(1.2, 1.2, 1.2)
		scale = Vector2(1.1, 1.1)
		z_index = 10
	else:
		modulate = Color(1, 1, 1)
		scale = Vector2(1, 1)
		z_index = 0
