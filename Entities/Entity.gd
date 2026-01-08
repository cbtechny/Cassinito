class_name Entity 
extends Node

const ACE_ALT_VALUE : int = 14
const SUIT_SPADE = "SPADES"
const SUIT_DIAMOND = "DIAMONDS"
const RANK_TEN = "TEN"
const RANK_TWO = "TWO"

var player_name : String
var is_entity_player : bool = false
var hand = Hand.new()
var has_big_cassino : bool = false
var has_little_cassino : bool = false
var ace_count : int = 0
var spade_count : int = 0
var swipe_count : int = 0
var card_pile_counter : int = 0
var captured_cards_pile : Array[ CardData ] = []
var swipe_cards_pile : Array[ CardData ] = []

func _init( _name : String, is_player : bool):
	player_name = _name
	is_entity_player = is_player

func choose_ace_value( card_data : CardData, use_alt_value : bool ) -> int:
	if not card_data.is_ace:
		return card_data.value
	if use_alt_value:
		card_data.value = ACE_ALT_VALUE
		return ACE_ALT_VALUE
	return 1

func calc_captured_total_score() -> int:
	var score : int = 0
	# Each ace is a point
	score += ace_count
	# Each swipe card is a point
	score += swipe_count
# Check if the player has the most spades
	if spade_count > 6:
		score += 1
# Big cassino : 2 points; Little cassino : 1 point
	if has_big_cassino:
		score += 2
	if has_little_cassino:
		score += 1
# Check if player has the most cards
	if captured_cards_pile.size() > 26:
		score += 1
	return score

func add_card( new_card : CardData ) -> void:
	if new_card.is_ace:
		ace_count += 1
	if new_card.is_spade:
		spade_count += 1
	if new_card.suit == SUIT_DIAMOND and new_card.rank == RANK_TEN:
		has_big_cassino = true  # 10 of Diamonds = Big Cassino (2 pts)
	if new_card.suit == SUIT_SPADE and new_card.rank == RANK_TWO:
		has_little_cassino = true  # 2 of Spades = Little Cassino (1 pt)
	hand.cards.append( new_card )

class CPU extends Entity:
	
	enum Difficulty{
		EASY,
		MEDIUM,
		HARD
	}

	var difficulty_level : Difficulty = Difficulty.EASY

	func _init( _difficulty : Difficulty ):
		super( "Opponent", false )
		difficulty_level = _difficulty