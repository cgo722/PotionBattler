extends Event
class_name HealEvent

@export var heal_amount: int = 10

func execute(game_manager):
	game_manager.character_resource.current_health += heal_amount
	print("Player healed for ", heal_amount, " health.")
	game_manager.state = game_manager.GameState.RUNNING
	game_manager.next_phase()
