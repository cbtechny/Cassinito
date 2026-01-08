class_name Hand

var cards : Array[ CardData ]
var card_count : int = 0

func get_card_count() -> int:
	return card_count

func add_card_to_hand( new_card_object : CardData) -> void:
	cards.append( new_card_object )
	card_count += 1

func remove_card_from_hand( card_object : CardData ) -> void:
	if card_object:
		cards.erase( card_object )
		card_count -= 1

#func get_card_value( card_object : CardData) -> int:
	#var card_rank_value : int = 0
	#if card_object.rank == "ACE":
		#pass
	#else:
		#card_object.value = card_rank_value
	#return card_rank_value
		
	
