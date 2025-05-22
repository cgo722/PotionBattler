extends Node

class_name Deck

@export var deck: Array = []        # The main draw pile
@export var hand: Array = []        # The player's current hand
@export var discard: Array = []     # The discard pile

@export var hand_limit: int = 5     # Max cards in hand

func shuffle_deck():
	deck.shuffle()

func draw_card():
	if deck.is_empty():
		reshuffle_discard_into_deck()
	if deck.is_empty():
		return null
	var card = deck.pop_front()
	if hand.size() >= hand_limit:
		# Overdraw: discard the oldest card in hand
		var oldest = hand.pop_front()
		discard.append(oldest)
	hand.append(card)
	return card

func draw_hand():
	while hand.size() < hand_limit:
		var card = draw_card()
		if card == null:
			break


func discard_card(card):
	if card in hand:
		hand.erase(card)
	discard.append(card)

func reshuffle_discard_into_deck():
	print("Reshuffling. Discard size:", discard.size())
	if discard.size() == 0:
		return
	for card in discard:
		deck.append(card)
	discard.clear()
	shuffle_deck()

func add_card_to_deck(card):
	deck.append(card)

func remove_card_from_deck(card):
	if card in deck:
		deck.erase(card)

func clear_all():
	deck.clear()
	hand.clear()
	discard.clear()

func remove_card_from_hand(card):
	if card in hand:
		hand.erase(card)
