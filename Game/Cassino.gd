class_name Cassino extends Node

signal swipe( _player : Entity )

var deck = Deck.new()
var cards_dealt : int = 0
var is_table_cleared : bool = false
