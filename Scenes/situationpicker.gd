extends HBoxContainer

var game_manager

func _ready():
	game_manager = get_node("/root/Gamemanager")
	randomize_buttons()

func randomize_buttons():
	var all_events = game_manager.get_possible_events()
	all_events.shuffle()
	var chosen_events = all_events.slice(0, 3)
	for i in range(3):
		var button = get_child(i)
		button.text = chosen_events[i]["name"]
		button.set_meta("event_data", chosen_events[i])
		button.connect("pressed", Callable(self, "_on_event_button_pressed").bind(chosen_events[i]))

func _on_event_button_pressed(event_data):
	print("Event chosen: ", event_data)
	game_manager.handle_event(event_data)
