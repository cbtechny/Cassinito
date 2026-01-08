class_name Entity extends Node


var player_name : String
var is_enity_player : bool = false
var has_big_cassino : bool = false
var has_little_cassino : bool = false
var ace_count : int = 0
var swipe_count : int = 0
var card_pile_counter : int = 0
var captured_cards_pile : Array[ CardData ]
var swipe_cards_pile : Array[ CardData ]

func _init( _name : String, is_player : bool):
	player_name = _name
	is_enity_player = is_player

class Player extends Entity:
	func _init():
		super(  "Player", true )

class CPU extends Entity:
	func _init():
		super( "Opponent", false )
