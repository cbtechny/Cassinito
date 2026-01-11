# # # Entity - Handles player and CPU-related game actions. The nested CPU class encapsulates bot functionality and decision logic.
class_name Entity
extends Node

# Constants
const ACE_HIGH_VALUE : int = 14
const SUIT_SPADE : String = "SPADES"
const SUIT_DIAMOND : String = "DIAMONDS"
const RANK_TEN : String = "TEN"
const RANK_TWO : String = "TWO"

# Init / identity
var player_name : String
var is_entity_player : bool = false

# Score state
var has_big_cassino : bool = false
var has_little_cassino : bool = false

# Card containers
var table_cards : Array[ CardData ] = []
var captured_cards_pile : Array[ CardData ] = []
var swipe_cards_pile : Array[ CardData ] = []

# Hand stores playable cards and tracks how many cards are in the hand, sending a "hand empty" signal
var hand : Hand = Hand.new()

func _init( _name : String, is_player : bool ) -> void:
	player_name = _name
	is_entity_player = is_player

# Helpers
static func flatten_cards( source : Array ) -> Array[ CardData ]:
# Normalize a mixed, possibly nested array of CardData and arrays into a flat. Array[CardData]. Recurses into nested arrays; ignores non-array, non-CardData items. Does not modify the input. Returns only valid CardData instances.
	var result : Array[ CardData ] = []
	for item in source:
		if item is CardData:
			result.append( item )
		elif item is Array:
			result.append_array( flatten_cards( item ) )
	return result

func evaluate_card_values( cards : Array, use_ace_high := false ) -> int:
# Sum values of a (possibly nested) collection of cards. When use_ace_high is true, Aces count as ACE_HIGH_VALUE (14); otherwise Aces count as 1.
	var total : int = 0
	var flat_cards := flatten_cards( cards )
	for card in flat_cards:
		if card.is_ace:
			total += ACE_HIGH_VALUE if use_ace_high else 1
		else:
			total += card.value
	return total

func count_cards( predicate : Callable ) -> int:
	# Count cards in captured_cards_pile that satisfy predicate(card : CardData) -> bool.
	# Returns 0 if predicate is not a valid Callable.
	if typeof( predicate ) != TYPE_CALLABLE or predicate.is_null():
		return 0
	var count : int = 0
	for card in captured_cards_pile:
		if predicate.call( card ):
			count += 1
	return count

func capture_card( card : CardData ) -> void:
	# Add a single CardData to captured_cards_pile and update score flags. Ignores null.
	if card == null:
		return
	if card.suit == SUIT_DIAMOND and card.rank == RANK_TEN:
		has_big_cassino = true
	if card.suit == SUIT_SPADE and card.rank == RANK_TWO:
		has_little_cassino = true
	captured_cards_pile.append( card )

func capture_pile_of_cards( cards : Array ) -> void:
	# Capture a build or pair by flattening nested arrays into CardData and capturing each.
	for card in flatten_cards( cards ):
		capture_card( card )

func calc_captured_total_score() -> int:
	# Compute score based on captured and swept cards:
	# +1 per Ace captured; +1 per sweep; +1 for most spades (spades > 6);
	# +2 for 10 of Diamonds; +1 for 2 of Spades; +1 for most cards (> 26 captured).
	var score : int = 0
	var ace_count := count_cards( func( c ) : return c.is_ace )
	var spade_count := count_cards( func( c ) : return c.is_spade )
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

# CPU - Bot functionality and decision-logic
class CPU extends Entity:
# Bot difficulty levels
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

# Choose the capture group with the highest sum using Ace low
	func evaluate_capture( possible_groups : Array ) -> Array:
		var best_value := -1
		var best_group : Array = []
		for group in possible_groups:
			var value := evaluate_card_values( group )
			if value > best_value:
				best_value = value
				best_group = group
		capture_tmp = best_group
		return best_group

# Choose the build group with the highest sum using Ace high
	func evaluate_build( possible_groups : Array ) -> Array:
		var best_value := -1
		var best_group : Array = []
		for group in possible_groups:
			var value := evaluate_card_values( group, true )
			if value > best_value:
				best_value = value
				best_group = group
		build_tmp = best_group
		return best_group

# Returns all single-card and multi-card capture groups for a given card.
# Each group is an Array of CardData that sums to card.value.
	func find_capture_groups( card : CardData, table : Array ) -> Array:
		var groups : Array = []
		var table_cards_list : Array[ CardData ] = []

# Extract CardData from table (may contain builds as nested arrays)
		for t in table:
			if t is CardData:
				table_cards_list.append( t )

# Single-card captures
		for t in table_cards_list:
			if t.value == card.value:
				groups.append( [ t ] )

# Multi-card captures via subset enumeration (practical for small tables)
		var n := table_cards_list.size()
		for mask in range( 2, 1 << n ):  # Start at 2 to skip empty and single-element sets
			var bits := _count_bits( mask )
			if bits < 2:
				continue
			var subset : Array[ CardData ] = []
			var total := 0
			for i in range( n ):
				if ( mask >> i ) & 1:
					subset.append( table_cards_list[ i ] )
					total += table_cards_list[ i ].value
			if total == card.value:
				groups.append( subset )

		return groups

# Returns possible build groups: subsets of table cards whose sum < card.value.
# A build lets the CPU later capture with a matching card.
	func find_build_groups( card : CardData, table : Array ) -> Array:
		var groups : Array = []
		var table_cards_list : Array[ CardData ] = []

		for t in table:
			if t is CardData:
				table_cards_list.append( t )

		var n := table_cards_list.size()
		for mask in range( 1, 1 << n ):
			var subset : Array[ CardData ] = []
			var total := 0
			for i in range( n ):
				if ( mask >> i ) & 1:
					subset.append( table_cards_list[ i ] )
					total += table_cards_list[ i ].value
# Valid build: sum < card value (we'll add card later to complete build)
			if total > 0 and total < card.value:
				groups.append( subset )

		return groups

# Generates all legal moves for the CPU's current hand and table state. Returns Array of Dictionaries: { type, card, groups (optional) }
	func get_all_legal_moves() -> Array:
		var moves : Array = []

		for card in hand.cards:
# Capture moves
			var captures := find_capture_groups( card, table_cards )
			if captures.size() > 0:
				moves.append( { "type": "capture", "card": card, "groups": captures } )

# Build moves
			var builds := find_build_groups( card, table_cards )
			if builds.size() > 0:
				moves.append( { "type": "build", "card": card, "groups": builds } )

# Trail (play card to table) is always legal
			moves.append( { "type": "trail", "card": card } )

		return moves

# Scoring

# Returns a bonus score for capturing high-value Casino cards.
	func casino_bonus( cards : Array ) -> float:
		var bonus := 0.0
		var flat := flatten_cards( cards )

		for c in flat:
			if c.is_ace:
				bonus += 1.0
			if c.is_spade:
				bonus += 0.25  # Helps "most spades"
			if c.suit == SUIT_DIAMOND and c.rank == RANK_TEN:
				bonus += 2.0  # Big Casino
			if c.suit == SUIT_SPADE and c.rank == RANK_TWO:
				bonus += 2.0  # Little Casino

		return bonus

# Checks if the group captures all table cards (a sweep).
	func is_sweep( group : Array ) -> bool:
		var flat := flatten_cards( group )
		var table_flat : Array[ CardData ] = []

		for t in table_cards:
			if t is CardData:
				table_flat.append( t )

		if flat.size() != table_flat.size() or table_flat.size() == 0:
			return false

		for c in flat:
			if not table_flat.has( c ):
				return false
		return true

	## Scores a single move for decision-making. Higher is better.
	func score_move( move : Dictionary ) -> float:
		var score := 0.0

		match move.type:
			"capture":
				var best_group_score := -INF
				for g in move.groups:
					var v : float = evaluate_card_values( g )
					v += casino_bonus( g )
					if is_sweep( g ):
						v += 1.5
					if v > best_group_score:
						best_group_score = v
				score = best_group_score
				score += move.card.value * 0.05  # Prefer using higher cards

			"build":
				var best_build_score := -INF
				for g in move.groups:
					var v : float = evaluate_card_values( g, true )
					v += casino_bonus( g ) * 0.8
					if v > best_build_score:
						best_build_score = v
				score = best_build_score * 0.9  # Builds slightly less valuable than captures

			"trail":
				score = move.card.value * 0.1
				# Penalize trailing valuable cards
				if move.card.suit == SUIT_SPADE and move.card.rank == RANK_TWO:
					score -= 3.0
				if move.card.suit == SUIT_DIAMOND and move.card.rank == RANK_TEN:
					score -= 2.0
				if move.card.is_spade:
					score -= 0.3

		# Add randomness for MEDIUM difficulty
		if difficulty_level == Difficulty.MEDIUM:
			score += randf_range( -0.3, 0.3 )

		return score

# Selects the best move from all legal options.
# Returns Dictionary with type, card, and chosen_group (for capture/build).
	func choose_best_move() -> Dictionary:
		var moves := get_all_legal_moves()
		if moves.is_empty():
			return {}

		var best_move : Dictionary = {}
		var best_score := -INF

		for move in moves:
			var s := score_move( move )
			if s > best_score:
				best_score = s
				best_move = move

# Attach best subgroup for capture/build moves
		if best_move.has( "groups" ):
			var best_sub : Array = []
			var best_sub_score := -INF
			var use_ace_high : bool = ( best_move.type == "build" )

			for g in best_move.groups:
				var v : float = evaluate_card_values( g, use_ace_high )
				v += casino_bonus( g ) * ( 0.8 if use_ace_high else 1.0 )
				if is_sweep( g ):
					v += 1.5
				if v > best_sub_score:
					best_sub_score = v
					best_sub = g

			best_move[ "chosen_group" ] = best_sub

		return best_move

# Executes a capture: removes card from hand, captures group from table.
	func execute_capture( card : CardData, group : Array ) -> void:
		hand.remove_card( card )

		for c in flatten_cards( group ):
			if table_cards.has( c ):
				table_cards.erase( c )
			capture_card( c )

		capture_card( card )

# Register sweep if table is cleared
		if table_cards.is_empty():
			swipe_cards_pile.append( card )

# Executes a build: removes card from hand, creates build structure on table.
	func execute_build( card : CardData, group : Array ) -> void:
		hand.remove_card( card )

		for c in flatten_cards( group ):
			if table_cards.has( c ):
				table_cards.erase( c )

# Store build as nested array so flatten_cards can extract CardData later
		table_cards.append( [ group, card ] )

# Executes a trail: plays card to table.
	func execute_trail( card : CardData ) -> void:
		hand.remove_card( card )
		table_cards.append( card )

	## Performs a full CPU turn: selects and executes the best move.
	func play_turn() -> void:
		var move := choose_best_move()
		if move.is_empty():
			return

		var group : Array = move.get( "chosen_group", [] )
		if group.is_empty() and move.has( "groups" ) and move.groups.size() > 0:
			group = move.groups[ 0 ]

		match move.type:
			"capture":
				execute_capture( move.card, group )
			"build":
				execute_build( move.card, group )
			"trail":
				execute_trail( move.card )

# Counts set bits in an integer (for subset enumeration).
	func _count_bits( n : int ) -> int:
		var count := 0
		while n > 0:
			count += n & 1
			n >>= 1
		return count

# Debug

	func debug_print_choice() -> void:
		var move := choose_best_move()
		if move.is_empty():
			print( "CPU: no legal move" )
			return
		print( "CPU chose: ", move.type, " with ", move.card )
		if move.has( "chosen_group" ):
			print( "  Group: ", move.chosen_group )
