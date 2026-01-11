# # #	Entity - This handles player and cpu-related game actions. Sub-class encapsulates CPU-specific functionality and logic
class_name Entity
extends Node
# Constants
const ACE_ALT_VALUE : int = 14
const SUIT_SPADE : String = "SPADES"
const SUIT_DIAMOND : String = "DIAMONDS"
const RANK_TEN : String = "TEN"
const RANK_TWO : String = "TWO"
# Init variables
var player_name : String
var is_entity_player : bool = false
# Score variables
var has_big_cassino : bool = false
var has_little_cassino : bool = false
# Cards
var captured_cards_pile: Array[ CardData ] = []
var swipe_cards_pile: Array[ CardData ] = []
var table_cards: Array = []

var hand := Hand.new()

func _init( _name : String, is_player : bool ) -> void:
	player_name = _name
	is_entity_player = is_player

func flatten_cards( source : Array ) -> Array[ CardData ]:
# Returns ("flattens") a mixed array of carddata and arrays of card data - like a mixed build - into an array of carddata. var result stores the result that is returned at the end of the function.
	var result : Array[ CardData ] = []

	for item in source:
# We checked the mixed array and add the item if it's a card and extract the card data in this recursive function to add it to the result.
		if item is CardData:
			result.append( item )
		elif item is Array:
			result.append_array( flatten_cards( item ) )
	return result


func evaluate_card_values( cards: Array, use_ace_high := false ) -> int:
# Calculate the total value of a hand of cards, considering Ace as high or low.
	var total : int = 0
# Flatten the input array to handle nested arrays of cards.
	var flat_cards := flatten_cards( cards )

	for card in flat_cards:
# Handle Ace cards separately, as their value depends on the context
		if card.is_ace:
# Use the alternative value (10 or 11) if use_ace_high is true, otherwise use 1.
			total += ACE_ALT_VALUE if use_ace_high else 1
		else:
			total += card.value
	return total


func count_cards( predicate : Callable ) -> int:
# Count the number of cards in any cards pile that match the given condition.
	var count : int = 0
	for card in captured_cards_pile:
# Call the predicate function on each card and increment count if it returns true.
		if predicate.call( card ):
			count += 1
	return count


func capture_card( card : CardData ) -> void:
	if card.suit == SUIT_DIAMOND and card.rank == RANK_TEN:
		has_big_cassino = true

	if card.suit == SUIT_SPADE and card.rank == RANK_TWO:
		has_little_cassino = true

	captured_cards_pile.append( card )


func capture_pile_of_cards( cards : Array ) -> void:
	for card in flatten_cards( cards ):
		capture_card( card )


func calc_captured_total_score() -> int:
	var score : int = 0

	var ace_count := count_cards( func( c ): return c.is_ace )
	var spade_count := count_cards( func( c ): return c.is_spade )
	var swipe_count := swipe_cards_pile.size()

	score += ace_count
	score += swipe_count

	if spade_count > 6:
		score += 1

	if has_big_cassino:
		score += 2

	if has_little_cassino:
		score += 1

	if captured_cards_pile.size() > 26:
		score += 1

	return score

class CPU extends Entity:

	enum Difficulty {
		MEDIUM,
		HARD
	}

	const DIFFICULTY := {
		"medium" : Difficulty.MEDIUM,
		"hard" : Difficulty.HARD
	}

	var difficulty_level : Difficulty
	var capture_tmp : Array = []
	var build_tmp : Array = []

	func _init( _difficulty : String ) -> void:
		super( "Opponent", false )
		difficulty_level = DIFFICULTY.get( _difficulty.to_lower(), Difficulty.MEDIUM )

	func evaluate_capture( possible_groups : Array ) -> void:
		var best_value := -1
		var best_group: Array = []

		for group in possible_groups:
			var value := evaluate_card_values( group )

			if value > best_value:
				best_value = value
				best_group = group

		capture_tmp = best_group


	func evaluate_build( possible_groups : Array ) -> void:
		var best_value := -1
		var best_group: Array = []

		for group in possible_groups:
			var value := evaluate_card_values( group, true )

			if value > best_value:
				best_value = value
				best_group = group

		build_tmp = best_group
