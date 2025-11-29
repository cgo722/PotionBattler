extends Event
class_name AddCardEvent

func execute(game_manager):
	var all_cards = CardDatabase.get_all_cards()
	if !all_cards.is_empty():
		var random_card = all_cards.pick_random()
		var card_instance = random_card.duplicate()
		game_manager.deck.add_card_to_deck(card_instance)
		print("Added random card to deck: ", card_instance.card_name)
	game_manager.state = game_manager.GameState.RUNNING
	game_manager.next_phase()
