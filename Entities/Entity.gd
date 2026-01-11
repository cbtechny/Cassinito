# Entity.gd
# Entity - This handles player and cpu-related game actions. Sub-class encapsulates CPU-specific functionality and logic
class_name Entity
extends Node

# Constants
const ACE_ALT_VALUE : int = 14
const SUIT_SPADE : String = "SPADES"
const SUIT_DIAMOND : String = "DIAMONDS"
const RANK_TEN : String = "TEN"
const RANK_TWO : String = "TWO"

# Init variables
const ACE_HIGH_VALUE : int = 14
var player_name : String
var is_entity_player : bool = false

# Score variables
var has_big_cassino : bool = false
var has_little_cassino : bool = false
var table_cards : Array[ CardData ] = []

# Cards
var hand : Hand = Hand.new()
var captured_cards_pile : Array[ CardData ] = []
var swipe_cards_pile : Array[ CardData ] = []
static func flatten_cards( source : Array ) -> Array[ CardData ]:
# Normalize a mixed, possibly nested array of CardData and arrays into a flat
# Array[CardData]. Recurses into nested arrays; ignores non-array, non-CardData
# items. Does not modify the input. Returns only valid CardData instances.

# Hand stores playable cards and tracks how many cards are in the hand, sending a "hand empty" signal
var hand := Hand.new()

func _init( _name : String, is_player : bool ) -> void:
	player_name = _name
	is_entity_player = is_player

func flatten_cards( source : Array ) -> Array[ CardData ]:
	# Returns ("flattens") a mixed array of CardData and arrays of CardData into a flat Array[CardData].
func evaluate_card_values( cards : Array, use_ace_high := false ) -> int:
# Sum values of a (possibly nested) collection of cards. When use_ace_high is
# true, Aces count as ACE_HIGH_VALUE (currently 14); otherwise Aces count as 1.

	for item in source:
		if item is CardData:
			result.append( item )
		elif item is Array:
			result.append_array( flatten_cards( item ) )
	return result
			# Use the high value when requested; otherwise treat Ace as 1.

func evaluate_card_values( cards : Array, use_ace_high := false ) -> int:
	# Calculate the total value of a hand of cards, considering Ace as high or low.
	var total : int = 0
	# Flatten the input array to handle nested arrays of cards.
	var flat_cards := flatten_cards( cards )
func count_cards( predicate : Callable ) -> int:
# Count cards in captured_cards_pile that satisfy predicate(card : CardData) -> bool.
# Returns 0 if predicate is not a valid Callable.
	if typeof(predicate) != TYPE_CALLABLE or predicate.is_null():
		return 0
	for card in flat_cards:
		# Handle Ace cards separately, as their value depends on the context
		if card.is_ace:
			# Use the alternative value (ACE_ALT_VALUE) if use_ace_high is true, otherwise use 1.
			total += ACE_ALT_VALUE if use_ace_high else 1
		else:
			total += card.value
	return total
func capture_card( card : CardData ) -> void:
# Add a single CardData to captured_cards_pile and update score flags. Ignores null.
	if card == null:
		return
# Check for special-case cards and update flags

func count_cards( predicate : Callable ) -> int:
	# Count the number of cards in captured_cards_pile that match the given condition.
	var count : int = 0
	for card in captured_cards_pile:
		# Call the predicate function on each card and increment count if it returns true.
		if predicate.call( card ):
	# Capture a build or pair group by flattening nested arrays into CardData
	# and capturing each card individually.
			count += 1
	return count

# Captures a single card data and updates counters
func calc_captured_total_score() -> int:
# Compute score based on captured and swept cards:
# +1 per Ace captured; +1 per sweep; +1 for most spades (spades > 6);
# +2 for 10 of Diamonds; +1 for 2 of Spades; +1 for most cards (> 26 captured).
	# Check for special-case cards and update flags
	if card.suit == SUIT_DIAMOND and card.rank == RANK_TEN:
		has_big_cassino = true
	if card.suit == SUIT_SPADE and card.rank == RANK_TWO:
		has_little_cassino = true
	captured_cards_pile.append( card )

# Captures a build or pair using flatten_cards function
func capture_pile_of_cards( cards : Array ) -> void:
	for card in flatten_cards( cards ):
		capture_card( card )


func calc_captured_total_score() -> int:
	# Checks the various piles and calculates the points
	var score : int = 0
	var ace_count := count_cards( func( c ) : return c.is_ace )
	var spade_count := count_cards( func( c ) : return c.is_spade )
	var swipe_count := swipe_cards_pile.size()

	score += ace_count
	score += swipe_count

	if spade_count > 6:
		score += 1

	if has_big_cassino:
	func evaluate_capture( possible_groups : Array ) -> Array:
		# Choose the capture group with the highest sum using Ace low (use_ace_high = false).

	if has_little_cassino:
		score += 1

	if captured_cards_pile.size() > 26:
		score += 1

	return score


# CPU (extends Entity) - Entity functionality and decision-handling for bot player
		return best_group
class CPU extends Entity:
	func evaluate_build( possible_groups : Array ) -> Array:
		# Choose the build group with the highest sum using Ace high (use_ace_high = true).
	enum Difficulty {
		MEDIUM,
		HARD
	}
	# Dictionary with string keys medium and hard to access Difficulty
	const DIFFICULTY := {
		"medium" : Difficulty.MEDIUM,
		"hard" : Difficulty.HARD
	}
	var difficulty_level : Difficulty

		return best_group
	# Temporary arrays to hold bot decision data
	var capture_tmp : Array = []
	var build_tmp : Array = []

	# Inits the bot player and sets the difficulty to default - MEDIUM
	func _init( _difficulty : String ) -> void:
		super( "Opponent", false )
		difficulty_level = DIFFICULTY.get( _difficulty.to_lower(), Difficulty.MEDIUM )

	# Evaluation logic for a capture where we take an array of cards and/or piles, and derive the best capture option
	func evaluate_capture( possible_groups : Array ) -> void:
		var best_value := -INF
		var best_group : Array = []

		for group in possible_groups:
			var value := evaluate_card_values( group )
			# Add casino-aware bonus when evaluating captures
			value += casino_bonus( group )

			if value > best_value:
				best_value = value
				best_group = group

		capture_tmp = best_group

	func evaluate_build( possible_groups : Array ) -> void:
		var best_value := -INF
		var best_group : Array = []

		for group in possible_groups:
			var value := evaluate_card_values( group, true )
			# Builds should consider future scoring potential
			value += casino_bonus( group ) * 0.8

			if value > best_value:
				best_value = value
				best_group = group

		build_tmp = best_group

	# --- Move generation helpers ---
	# NOTE: These helper functions assume game rules functions exist to determine legal groups.
	# If your project has different names for these helpers, replace the internals accordingly.

	func find_capture_groups( card : CardData, table : Array ) -> Array:
		# Returns an array of possible capture groups (each group can be CardData or nested arrays representing builds).
		# Simple implementation: capture any single table card equal to card.value, or any combination summing to card.value.
		# This is a naive subset-sum approach for small table sizes; replace with optimized logic if needed.
		var groups : Array = []

		# Single-card captures
		for t in table:
			if t is CardData and t.value == card.value:
				groups.append( [ t ] )

		# Multi-card captures (combinations)
		var table_cards_list := []
		for t in table:
			if t is CardData:
				table_cards_list.append( t )

		var n := table_cards_list.size()
		# brute-force subsets (only reasonable for small n)
		for mask in range(1, 1 << n):
			var subset := []
			var sum := 0
			for i in range(n):
				if (mask >> i) & 1:
					subset.append( table_cards_list[i] )
					sum += table_cards_list[i].value
			if sum == card.value:
				groups.append( subset )

		# If card can capture everything (sweep), include that as a high-value group
		if evaluate_card_values( table_cards_list ) == card.value and table_cards_list.size() > 0:
			groups.append( table_cards_list.duplicate() )

		return groups

	func find_build_groups( card : CardData, table : Array ) -> Array:
		# Returns possible build groups that include the card and some table cards.
		# For simplicity: allow building on any table card or combination where sum < card.value (so future capture possible).
		var groups : Array = []
		var table_cards_list := []
		for t in table:
			if t is CardData:
				table_cards_list.append( t )

		var n := table_cards_list.size()
		# single builds (card + single table card)
		for t in table_cards_list:
			var sum := t.value + 0 # building uses card as target; we store the group that would represent the build
			if sum < card.value:
				groups.append( [ t ] )

		# multi-card builds (combinations)
		for mask in range(1, 1 << n):
			var subset := []
			var sum := 0
			for i in range(n):
				if (mask >> i) & 1:
					subset.append( table_cards_list[i] )
					sum += table_cards_list[i].value
			if sum < card.value:
				groups.append( subset )

		return groups

	# --- Casino-aware scoring ---
	func casino_bonus( cards : Array ) -> float:
		# Returns a small bonus (float) representing Casino scoring priorities:
		# - Big Casino (10 of Diamonds) -> +2
		# - Little Casino (2 of Spades) -> +2
		# - Each Ace -> +1
		# - Each Spade -> +0.25 (helps Most Spades)
		# - Avoid leaving spades on table (negative when evaluating trails)
		var bonus : float = 0.0
		var flat := flatten_cards( cards )

		for c in flat:
			if c.is_ace:
				bonus += 1.0
			if c.is_spade:
				bonus += 0.25
			if c.suit == SUIT_DIAMOND and c.rank == RANK_TEN:
				bonus += 2.0
			if c.suit == SUIT_SPADE and c.rank == RANK_TWO:
				bonus += 2.0

		return bonus

	# --- Move generation (all legal moves for current hand + table) ---
	func get_all_legal_moves() -> Array:
		# Each move is a Dictionary:
		# { "type": "capture"|"build"|"trail", "card": CardData, "groups": Array (optional) }
		var moves : Array = []
		for card in hand.cards:
			# captures
			var captures := find_capture_groups( card, table_cards )
			if captures.size() > 0:
				moves.append( { "type":"capture", "card":card, "groups":captures } )

			# builds
			var builds := find_build_groups( card, table_cards )
			if builds.size() > 0:
				moves.append( { "type":"build", "card":card, "groups":builds } )

			# trail (play to table) is always legal
			moves.append( { "type":"trail", "card":card } )

		return moves

	# --- Score a single move (returns float for fine-grained heuristics) ---
	func score_move( move : Dictionary ) -> float:
		var score : float = 0.0

		match move.type:
			"capture":
				# Evaluate best group for this card (choose group that maximizes value + casino bonus)
				var best_group_score := -INF
				var best_group := null
				for g in move.groups:
					var v := evaluate_card_values( g )
					v += casino_bonus( g )
					# prefer sweeps and groups that capture spades/aces
					if is_sweep_group( g ):
						v += 1.5
					if v > best_group_score:
						best_group_score = v
						best_group = g
				score = best_group_score
				# small preference for using higher-value card to capture (denies opponent)
				score += move.card.value * 0.05

			"build":
				# Evaluate best build group
				var best_build_score := -INF
				for g in move.groups:
					var v := evaluate_card_values( g, true )
					v += casino_bonus( g ) * 0.8
					# penalize builds that create obvious captures for opponent (simple heuristic)
					if leaves_easy_capture_for_opponent( move.card, g ):
						v -= 0.8
					if v > best_build_score:
						best_build_score = v
				score = best_build_score
				# builds are slightly less valuable than immediate captures
				score *= 0.9

			"trail":
				# Trails are low-value; but avoid trailing high-value scoring cards
				score = move.card.value * 0.1
				# penalize trailing spade two or ten of diamonds heavily
				if move.card.suit == SUIT_SPADE and move.card.rank == RANK_TWO:
					score -= 3.0
				if move.card.suit == SUIT_DIAMOND and move.card.rank == RANK_TEN:
					score -= 2.0
				# penalize trailing spades in HARD difficulty more strongly
				if difficulty_level == Difficulty.HARD and move.card.is_spade:
					score -= 0.5

		# Difficulty adjustments: MEDIUM adds some randomness; HARD is deterministic
		if difficulty_level == Difficulty.MEDIUM:
			# add small random noise so medium bot is less predictable
			score += randf_range( -0.3, 0.3 )

		return score

	# Helper: detect if a group is a sweep (captures all table cards)
	func is_sweep_group( group : Array ) -> bool:
		var flat := flatten_cards( group )
		# If group contains all table cards (by identity), it's a sweep
		var table_flat := []
		for t in table_cards:
			if t is CardData:
				table_flat.append( t )
		if flat.size() == table_flat.size():
			# quick identity check
			for c in flat:
				if not table_flat.has( c ):
					return false
			return true
		return false

	# Heuristic: does this build leave an easy capture for opponent?
	func leaves_easy_capture_for_opponent( card : CardData, build_group : Array ) -> bool:
		# Very simple heuristic: if the build sum equals a common card value (like 10 or 14) or leaves a single high card on table
		var sum := evaluate_card_values( build_group, true )
		# If sum equals 10 or 14 (ace high) it's often risky
		if sum == 10 or sum == ACE_ALT_VALUE:
			return true
		# If build removes many cards and leaves a single high-value card on table, risky
		var remaining := table_cards.duplicate()
		for c in flatten_cards( build_group ):
			if remaining.has( c ):
				remaining.erase( c )
		if remaining.size() == 1:
			var rem := remaining[0]
			if rem.value >= 10:
				return true
		return false

	# --- Choose best move from all legal moves ---
	func choose_best_move() -> Dictionary:
		var moves := get_all_legal_moves()
		if moves.size() == 0:
			return {}

		var best_move := null
		var best_score := -INF

		for move in moves:
			var s := score_move( move )
			if s > best_score:
				best_score = s
				best_move = move

		# For capture/build moves, attach the chosen subgroup (best group) for execution
		if best_move != null and (best_move.type == "capture" or best_move.type == "build"):
			var best_sub := null
			var best_sub_score := -INF
			for g in best_move.groups:
				var v := evaluate_card_values( g, best_move.type == "build" )
				v += casino_bonus( g ) * (0.8 if best_move.type == "build" else 1.0)
				if is_sweep_group( g ):
					v += 1.5
				if v > best_sub_score:
					best_sub_score = v
					best_sub = g
			best_move["chosen_group"] = best_sub

		return best_move

	# --- Execute move (mutates hand, table, and captured piles) ---
	func execute_capture( card : CardData, group : Array ) -> void:
		# Remove card from hand
		hand.remove_card( card )
		# Remove captured cards from table and add to captured pile
		for c in flatten_cards( group ):
			if table_cards.has( c ):
				table_cards.erase( c )
			capture_card( c )
		# Also capture the played card
		capture_card( card )
		# If capture cleared table, register a swipe
		if table_cards.size() == 0:
			swipe_cards_pile.append( card )

	func execute_build( card : CardData, group : Array ) -> void:
		# Remove card from hand and create a build on the table (represented as nested array)
		hand.remove_card( card )
		# Remove group cards from table and replace with a build structure [ group, build_owner_card_value ]
		for c in flatten_cards( group ):
			if table_cards.has( c ):
				table_cards.erase( c )
		# Represent build as [ group, card ] so flatten_cards can still extract CardData
		table_cards.append( [ group, card ] )

	func execute_trail( card : CardData ) -> void:
		# Play card to table
		hand.remove_card( card )
		table_cards.append( card )

	# --- Public: perform a full CPU turn (choose and execute) ---
	func play_turn() -> void:
		var move := choose_best_move()
		if move == null or move.empty():
			return

		match move.type:
			"capture":
				var group := move.get("chosen_group", null)
				if group == null:
					# fallback: pick first available group
					group = move.groups[0]
				execute_capture( move.card, group )

			"build":
				var group := move.get("chosen_group", null)
				if group == null:
					group = move.groups[0]
				execute_build( move.card, group )

			"trail":
				execute_trail( move.card )

		# Optionally, emit a signal or call a callback to notify the game manager that the CPU has played.
		# emit_signal("turn_completed", self)

	# --- Utility: debug print of decision (optional) ---
	func debug_print_choice() -> void:
		var move := choose_best_move()
		if move == null:
			print("CPU: no move")
			return
		print("CPU chose: ", move.type, " card=", move.card)
		if move.has("chosen_group"):
			print(" group=", move.chosen_group)
