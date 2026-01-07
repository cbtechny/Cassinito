class_name Entity extends Node


var player_name : String
var is_enity_player : bool = false
var has_big_cassino : bool = false
var has_little_cassino : bool = false
var ace_count : int = 0
var swipe_count : int = 0
var card_pile_counter : int = 0

class Player extends Entity:
	func _init() -> void:
		player_name = "Player"
		is_enity_player = true

class CPU extends Entity:
	func _init() -> void:
		player_name = "Opponent"
