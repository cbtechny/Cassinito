class_name CardData

var rank : String  # Card rank as string (e.g., "ACE", "KING", "SEVEN")
var suit : String  # Card suit as string (e.g., "HEARTS", "SPADES")
var value : int    # Numeric value for Royal Cassino  ( 1-13 )
var is_ace : bool  # True if this is an Ace
var is_spade : bool # True if this is a Spade

func _init( 
	_r := "",  # Rank (default empty)
	_s := "",  # Suit (default empty)
	_v := 0,   # Value (default 0)
	_is_ace := false,  # Is ace flag (default false)
	_is_spade := false
): 
	rank = _r
	suit = _s
	value = _v
	is_ace = _is_ace
	is_spade = _is_spade
	
# Debug helper (uncomment for testing)
# Returns a human-readable string representation of the card
#func to_string() -> String:
	#return "%s of %s | Value: %d | Is Ace: %s" % [rank, suit, value, is_ace]
