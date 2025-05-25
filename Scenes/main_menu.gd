extends Control
@export var gamemanager : NodePath # Set this to your GameManager node in the editor

func _on_start_game_button_down() -> void:
	get_node(gamemanager).start_run()
	pass # Replace with function body.
