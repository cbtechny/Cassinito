class_name Cassino
extends Control

signal swipe() # already declared, reuse

# --- Nodes / scenes ---
@onready var player_hand_box : HBoxContainer = $GameArea/PlayersMargin/Players/Player/Player/card_box
@onready var cpu_hand_box    : HBoxContainer = $GameArea/PlayersMargin/Players/Opponent/Player/card_box
@onready var table_box       : HBoxContainer = $UI/TableCards

@onready var player_captured_label : Label = $GameArea/PlayersMargin/Players/Player/Player/player_planel/vbox/cards/captured_amount_label
@onready var player_swipe_label    : Label = $GameArea/PlayersMargin/Players/Player/Player/player_planel/vbox/cards/swipe_amount_label
@onready var player_hand_label     : Label = $GameArea/PlayersMargin/Players/Player/Player/player_planel/vbox/cards/hand_remain_label

@onready var cpu_captured_label : Label = $GameArea/PlayersMargin/Players/Opponent/Player/player_planel/vbox/cards/captured_amount_label
@onready var cpu_swipe_label    : Label = $GameArea/PlayersMargin/Players/Opponent/Player/player_planel/vbox/cards/swipe_amount_label
@onready var cpu_hand_label     : Label = $GameArea/PlayersMargin/Players/Opponent/Player/player_planel/vbox/cards/hand_remain_label

const CARD_SCENE_PATH := "res://Game/Cards/Card.tscn"
var CardScene : PackedScene

# --- Game model ---
var deck : Deck = Deck.new()
var table_cards : Array[CardData] = []

var player : Entity
var cpu    : Entity.CPU

enum TurnState { DEAL, PLAYER_TURN, CPU_TURN, ROUND_END }
var state : TurnState = TurnState.DEAL

# Map CardData -> card Control node
var card_to_node : Dictionary = {}
var node_to_card : Dictionary = {}

# Selection state for the player's move
var selected_hand_card : CardData = null
var selected_table_cards : Array[CardData] = []

func _ready() -> void:
	CardScene = load(CARD_SCENE_PATH)
	_init_game()

func _init_game() -> void:
	# Prepare deck and entities
	deck.create_deck()
	deck.shuffle_deck()

	player = Entity.new("You", true)
	cpu    = Entity.CPU.new("medium") # or "hard"

	# Share the same table array with entities
	player.table_cards = table_cards
	cpu.table_cards    = table_cards

	_deal_initial()
	state = TurnState.PLAYER_TURN
	_refresh_all_ui()


func _free_children(node: Node) -> void:
	for i in range(node.get_child_count()):
		node.get_child(i).queue_free()


# --- Dealing ---

func _deal_initial() -> void:
	# give 4 cards each and 4 to table
	_clear_all_visuals()
	_deal_cards_to_entity(player, 4)
	_deal_cards_to_entity(cpu, 4)
	_deal_cards_to_table(4)

func _deal_cards_to_entity(e : Entity, count : int) -> void:
	for i in range(count):
		if deck.deck_card_pile.is_empty():
			return
		var card_data : CardData = deck.deck_card_pile.pop_back()
		e.hand.add_card_to_hand(card_data)
		_spawn_hand_card(e, card_data)

func _deal_cards_to_table(count : int) -> void:
	for i in range(count):
		if deck.deck_card_pile.is_empty():
			return
		var card_data : CardData = deck.deck_card_pile.pop_back()
		table_cards.append(card_data)
		_spawn_table_card(card_data)

func _clear_all_visuals() -> void:
	_free_children(player_hand_box)
	_free_children(cpu_hand_box)
	_free_children(table_box)
	card_to_node.clear()
	node_to_card.clear()

# --- Card instance helpers ---

func _spawn_hand_card(e : Entity, card_data : CardData) -> void:
	var card_node : Control = CardScene.instantiate()
	# TODO: set card_node's texture region from card_data.texture_map_region
	# and flip for CPU if desired (show back).
	card_to_node[card_data] = card_node
	node_to_card[card_node] = card_data

	if e.is_entity_player:
		player_hand_box.add_child(card_node)
		# connect click for player
		card_node.gui_input.connect(_on_player_hand_card_input.bind(card_node))
	else:
		cpu_hand_box.add_child(card_node) # likely face‑down, no click

	_refresh_hand_labels()

func _spawn_table_card(card_data : CardData) -> void:
	var card_node : Control = CardScene.instantiate()
	card_to_node[card_data] = card_node
	node_to_card[card_node] = card_data
	table_box.add_child(card_node)
	# Allow player selecting table cards
	card_node.gui_input.connect(_on_table_card_input.bind(card_node))

# --- Input handling ---

func _on_player_hand_card_input(event: InputEvent, node: Control) -> void:
	if state != TurnState.PLAYER_TURN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var card_data : CardData = node_to_card.get(node, null)
		if card_data == null:
			return
		_select_hand_card(card_data, node)

func _on_table_card_input(event: InputEvent, node: Control) -> void:
	if state != TurnState.PLAYER_TURN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var card_data : CardData = node_to_card.get(node, null)
		if card_data == null:
			return
		_toggle_table_selection(card_data, node)

func _select_hand_card(card : CardData, node : Control) -> void:
	selected_hand_card = card
	selected_table_cards.clear()
	_highlight_selection() # you can implement some visual tint

func _toggle_table_selection(card : CardData, node : Control) -> void:
	if card in selected_table_cards:
		selected_table_cards.erase(card)
	else:
		selected_table_cards.append(card)
	_highlight_selection()

func _highlight_selection() -> void:
	# Deselect all cards first
	for card_data in card_to_node:
		var node = card_to_node[card_data]
		if node:
			var overlay = node.get_node_or_null("SelectionOverlay")
			if overlay:
				overlay.visible = false

	# Highlight the hand card
	if selected_hand_card:
		var hand_node = card_to_node.get(selected_hand_card)
		if hand_node:
			var overlay = hand_node.get_node_or_null("SelectionOverlay")
			if overlay:
				overlay.visible = true

	# Highlight table cards
	for table_card in selected_table_cards:
		var table_node = card_to_node.get(table_card)
		if table_node:
			var overlay = table_node.get_node_or_null("SelectionOverlay")
			if overlay:
				overlay.visible = true

# Called from a "Play" button in the UI or double‑click, etc.
func _on_confirm_move_pressed() -> void:
	if state != TurnState.PLAYER_TURN or selected_hand_card == null:
		return

	# Decide capture / build / trail based on selection + rules.
	var move_type := _classify_player_move()
	match move_type:
		"capture":
			_player_capture(selected_hand_card, selected_table_cards)
		"build":
			_player_build(selected_hand_card, selected_table_cards)
		"trail":
			_player_trail(selected_hand_card)
		_:
			return

	_end_player_turn()

func _classify_player_move() -> String:
	if selected_table_cards.is_empty():
		# No table cards selected, so either trail or invalid.
		# For now, treat as trail.
		return "trail"

	# Check if selected_table_cards sum to the hand card (capture)
	var sum := player.evaluate_card_values(selected_table_cards)
	if sum == selected_hand_card.value:
		return "capture"

	# Check for build: sum < value and player has matching card in hand
	if sum < selected_hand_card.value:
		for c in player.hand.cards:
			if c.value == selected_hand_card.value:
				return "build"

	# Fallback: trail (or could be invalid)
	return "trail"

# --- Execute player moves ---

func _player_capture(card : CardData, group : Array[CardData]) -> void:
	# Remove visuals
	_remove_hand_visual(card, player)
	for g in group:
		_remove_table_visual(g)

	# Update model (reuse Entity helpers)
	player.capture_pile_of_cards(group)
	player.capture_card(card)
	player.hand.remove_card_from_hand(card)

	if table_cards.is_empty():
		player.swipe_cards_pile.append(card)
		emit_signal("swipe")

	_refresh_all_ui()

func _player_build(card : CardData, group : Array[CardData]) -> void:
	_remove_hand_visual(card, player)
	for g in group:
		_remove_table_visual(g)

	# Store build as nested array same way CPU does
	for g in group:
		if table_cards.has(g):
			table_cards.erase(g)
	table_cards.append([group, card])

	player.hand.remove_card_from_hand(card)
	_refresh_all_ui()

func _player_trail(card : CardData) -> void:
	_remove_hand_visual(card, player)
	player.hand.remove_card_from_hand(card)
	table_cards.append(card)
	_spawn_table_card(card) # re‑spawn linked to table_box
	_refresh_all_ui()

func _remove_hand_visual(card : CardData, e : Entity) -> void:
	var node : Control = card_to_node.get(card, null)
	if node:
		node.queue_free()
		card_to_node.erase(card)
		node_to_card.erase(node)
	_refresh_hand_labels()

func _remove_table_visual(card : CardData) -> void:
	var node : Control = card_to_node.get(card, null)
	if node:
		node.queue_free()
		card_to_node.erase(card)
		node_to_card.erase(node)
	if table_cards.has(card):
		table_cards.erase(card)

# --- Turn flow ---

func _end_player_turn() -> void:
	selected_hand_card = null
	selected_table_cards.clear()
	_highlight_selection()

	# If both hands empty and deck has cards, deal next batch
	if player.hand.card_count == 0 and cpu.hand.card_count == 0 and not deck.deck_card_pile.is_empty():
		_deal_cards_to_entity(player, 4)
		_deal_cards_to_entity(cpu, 4)
		_refresh_all_ui()

	# If deck empty and hands empty, round end
	if player.hand.card_count == 0 and cpu.hand.card_count == 0 and deck.deck_card_pile.is_empty():
		_end_round()
		return

	# CPU turn
	state = TurnState.CPU_TURN
	await get_tree().create_timer(0.5).timeout
	_cpu_turn()

func _cpu_turn() -> void:
	# CPU already has AI logic; just call play_turn.
	cpu.play_turn()
	# We need to sync visuals from model to UI — easiest is to rebuild visuals from scratch:
	_rebuild_all_visuals()

	# Same deal logic as player
	if player.hand.card_count == 0 and cpu.hand.card_count == 0 and not deck.deck_card_pile.is_empty():
		_deal_cards_to_entity(player, 4)
		_deal_cards_to_entity(cpu, 4)

	if player.hand.card_count == 0 and cpu.hand.card_count == 0 and deck.deck_card_pile.is_empty():
		_end_round()
		return

	state = TurnState.PLAYER_TURN
	_refresh_all_ui()

func _rebuild_all_visuals() -> void:
	_clear_all_visuals()
	# Recreate hand & table nodes from model
	for c in player.hand.cards:
		_spawn_hand_card(player, c)
	for c in cpu.hand.cards:
		_spawn_hand_card(cpu, c)

	for t in table_cards:
		if t is CardData:
			_spawn_table_card(t)
		# If you later support nested builds, handle unpacking here.

# --- Round end & scoring ---

func _end_round() -> void:
	state = TurnState.ROUND_END
	var player_score := player.calc_captured_total_score()
	var cpu_score    := cpu.calc_captured_total_score()
	print("Round finished. Player:", player_score, " CPU:", cpu_score)
	# TODO: Show game‑over UI / go to GAME_OVER scene, or track multiple rounds.

# --- UI labels ---

func _refresh_hand_labels() -> void:
	player_hand_label.text = str(player.hand.card_count)
	cpu_hand_label.text    = str(cpu.hand.card_count)

func _refresh_all_ui() -> void:
	_refresh_hand_labels()
	player_captured_label.text = str(player.captured_cards_pile.size())
	player_swipe_label.text    = str(player.swipe_cards_pile.size())
	cpu_captured_label.text    = str(cpu.captured_cards_pile.size())
	cpu_swipe_label.text       = str(cpu.swipe_cards_pile.size())
