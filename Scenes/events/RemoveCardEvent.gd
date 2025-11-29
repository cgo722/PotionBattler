extends Event
class_name RemoveCardEvent

func execute(game_manager):
	if !game_manager.deck.deck.is_empty():
		var card_to_remove = game_manager.deck.deck.pick_random()
		game_manager.deck.remove_card_from_deck(card_to_remove)
		print("Removed random card from deck: ", card_to_remove.card_name)
	else:
		print("No cards in deck to remove.")
	game_manager.state = game_manager.GameState.RUNNING
	game_manager.next_phase()
