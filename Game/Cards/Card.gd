extends Control
# Card visual controller - handles displaying card faces, backs, and flip animations

@onready var card_face : Sprite2D = $txtr_container/card_face
@onready var card_back : AnimatedSprite2D = $txtr_container/BackCardSprite
@onready var shadow : Sprite2D = $txtr_container/shadow
@onready var ace_config : Control = $AceConfig
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var card_data : CardData = null
var is_face_up : bool = true

# Animation constants
const FLIP_DURATION : float = 0.3
var is_flipping : bool = false

func _ready() -> void:
	# Default state
	show_back()

# Set the card's visual data and optionally flip to show it
func setup_card(data : CardData, show_front : bool = true) -> void:
	card_data = data
	if data:
		# Load the main texture
		var main_texture = load(CardAssets.FACES_TXR_PATH)
		
		# Create AtlasTexture to show only the region for this card
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = main_texture
		atlas_texture.region = data.texture_map_region
		
		# Set the texture for face and shadow
		card_face.texture = atlas_texture
		shadow.texture = atlas_texture
		
		# Show/hide ace hint for ace cards
		if data.is_ace:
			ace_config.visible = show_front
		else:
			ace_config.visible = false
	
	if show_front:
		show_front_immediate()
	else:
		show_back_immediate()

# Immediately show the front of the card (no animation)
func show_front_immediate() -> void:
	is_face_up = true
	card_face.visible = true
	shadow.visible = true
	card_back.visible = false
	if card_data and card_data.is_ace:
		ace_config.visible = true

# Immediately show the back of the card (no animation)
func show_back_immediate() -> void:
	is_face_up = false
	card_face.visible = false
	shadow.visible = false
	card_back.visible = true
	ace_config.visible = false

# Show the front (alias for consistency)
func show_front() -> void:
	show_front_immediate()

# Show the back (alias for consistency)
func show_back() -> void:
	show_back_immediate()

# Flip animation from back to front
func flip_to_front() -> void:
	if is_flipping or is_face_up:
		return
	
	is_flipping = true
	
	# Create a tween for the flip animation
	var tween = create_tween()
	tween.set_parallel(false)
	
	# Scale down horizontally (first half of flip)
	tween.tween_property(self, "scale:x", 0.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN)
	
	# Switch from back to front at the middle
	tween.tween_callback(func():
		card_back.visible = false
		card_face.visible = true
		shadow.visible = true
		if card_data and card_data.is_ace:
			ace_config.visible = true
	)
	
	# Scale back up (second half of flip)
	tween.tween_property(self, "scale:x", 1.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func():
		is_face_up = true
		is_flipping = false
	)

# Flip animation from front to back
func flip_to_back() -> void:
	if is_flipping or not is_face_up:
		return
	
	is_flipping = true
	
	# Create a tween for the flip animation
	var tween = create_tween()
	tween.set_parallel(false)
	
	# Scale down horizontally (first half of flip)
	tween.tween_property(self, "scale:x", 0.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_IN)
	
	# Switch from front to back at the middle
	tween.tween_callback(func():
		card_face.visible = false
		shadow.visible = false
		ace_config.visible = false
		card_back.visible = true
	)
	
	# Scale back up (second half of flip)
	tween.tween_property(self, "scale:x", 1.0, FLIP_DURATION / 2.0).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func():
		is_face_up = false
		is_flipping = false
	)
