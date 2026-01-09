extends Node

const FACES_TXR_PATH : String = "res://Game/Cards/Textures/128x178_52_FullDeck.png"
const CARD_SCENE_PATH : String = "res://Game/Card.tscn"
const BACKS_TXR_PATH : String = "res://Game/Cards/Textures/CardBacks.png"
const BACK_SPRITE_SCENE_PATH : String = "res://Game/Cards/back_card_sprite.tscn"
const FACE_SPRITE_CARD_WIDTH : int = 128
const FACE_SPRITE_CARD_LENGTH : int = 178

enum CardBackOptions {

		NPRA_DEFAULT_BLACK,
		NPRA_WHITE,
		NPRA_RED,
		NPRA_BLUE

	}

const BACK_SPRITE_ANIM_FRAME := {

	CardBackOptions.NPRA_DEFAULT_BLACK : 0,
	CardBackOptions.NPRA_WHITE : 1,
	CardBackOptions.NPRA_RED : 2,
	CardBackOptions.NPRA_BLUE : 3

	}

var back_sprite_scene : PackedScene = preload( BACK_SPRITE_SCENE_PATH )
var current_card_back : int = 0

func create_card_back() -> AnimatedSprite2D:
		var back_scene = back_sprite_scene.instantiate() as AnimatedSprite2D
		back_scene.frame = BACK_SPRITE_ANIM_FRAME[ current_card_back ]
		return back_scene

func change_card_backs( _card_back_option : int ) -> void:
	if _card_back_option < CardBackOptions.size():
		current_card_back = _card_back_option
	else:
		current_card_back = 0
		push_error( "No card option; default card back activated instead." )
