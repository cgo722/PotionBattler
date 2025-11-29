extends Resource
class_name Event
@export var name: String
@export var type: String
@export var description: String
@export var enemy: Resource
# Add more fields as needed (e.g., icon, effect, etc.)

func execute(game_manager):
	# Base implementation, should be overridden by subclasses
	print("Warning: Base Event.execute() called. No action taken.")
	# Default behavior to prevent getting stuck:
	game_manager.state = game_manager.GameState.RUNNING
	game_manager.next_phase()