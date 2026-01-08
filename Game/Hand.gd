class_name Hand
# This class manages the player's hand of cards in the game and keeps track of the number of cards held. Main signal: hand_empty - emitted when the player's hand is empty.
signal hand_empty

const MAX_CARDS : int = 4

var cards : Array[ CardData ]
var card_count : int = 0

func get_card_count() -> int:
	return card_count

func add_card_to_hand( new_card_object : CardData) -> void:
# Re: if statement prevents adding more than four cards to the player's hand, and a safety check to make sure duplicate cards are not added, then at the end, Aupdates the hand card counter
    if card_count < MAX_CARDS and new_card_object not in cards:
	    cards.append( new_card_object )
	    card_count += 1

func remove_card_from_hand( card_object : CardData ) -> void:
# Re: (below) removes a card from the player's hand and updates the hand card counter. We then check to make sure the hand is empty and emit a signal if so.
	if card_object and card_object in cards:
		cards.erase( card_object )
		card_count -= 1
        if card_count == 0:
            emit_signal("hand_empty")

#func get_card_value( card_object : CardData) -> int:
	#var card_rank_value : int = 0
	#if card_object.rank == "ACE":
		#pass
	#else:
		#card_object.value = card_rank_value
	#return card_rank_value
		
	
