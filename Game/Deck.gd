class_name Deck # Creates a 52-card deck full of data card objects with rank, suit and value
# Below, find enums and constants for deck creation
# Re: Rank - standard 52-card deck ranks (enum)
enum Rank {
	ACE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
}
# Re: Suit - Standard four suits for a 52-card deck (enum)
enum Suit {
	CLUBS,
	DIAMONDS,
	HEARTS,
	SPADES
}
# Re: CARD_VALUES - Royal Cassino variant changes face card values from [ 10 ] to (from Jack to King) 11, 12, 13. Aces can interchange between 1 and 14. Base value will be 1 (constant)
const CARD_VALUES = {
	Rank.ACE : 1,
	Rank.TWO : 2,
	Rank.THREE : 3,
	Rank.FOUR : 4,
	Rank.FIVE : 5,
	Rank.SIX : 6,
	Rank.SEVEN : 7,
	Rank.EIGHT : 8,
	Rank.NINE : 9,
	Rank.TEN : 10,
	Rank.JACK : 11,
	Rank.QUEEN : 12,
	Rank.KING : 13
}

# Re: deck_card_pile - holds the card objects created by create_deck()
var deck_card_pile : Array[ CardData ]

func create_deck() -> void:
	deck_card_pile.clear() # Safety check - clears card pile in case there are any cards in the pile
	for rank in Rank.values(): # Iterate through the Rank enum (adds a rank "ACE, TWO..." to the card object created in line 49)
		for suit in Suit.values(): # Iterate through the Suit enum (adds a suit, "CLUBS, DIAMONDS...")
			var card_data = CardData.new(
				Rank.keys()[ rank ],
				Suit.keys()[ suit ],
				CARD_VALUES[ rank ],
				rank == Rank.ACE,
				suit == Suit.SPADES
				) # With each iteration, a new card data is created with rank, suit, value, and whether it is an Ace-rank card
			deck_card_pile.append( card_data ) # Each card created is dadded to the pile
			shuffle_deck() # Efficient shuffle dor card data objects

func map_card_texture_region( ) -> void:
	pass

func shuffle_deck() -> void:
	deck_card_pile.shuffle()

# The card data objects will be used to create card scenes
