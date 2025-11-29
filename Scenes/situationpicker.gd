extends HBoxContainer

signal enemy_chosen(enemy_resource)

var game_manager

func _ready():
	game_manager = get_node("/root/Gamemanager")
	# Connect the buttons only once.
	for button in get_children():
		if button is Button:
			button.connect("pressed", Callable(self, "_on_event_button_pressed").bind(button))
	randomize_buttons()

func randomize_buttons():
	var all_events = game_manager.get_possible_events()
	all_events.shuffle()
	var chosen_events = all_events.slice(0, 3)
	for i in range(3):
		var button = get_child(i)
		# Only update the text and metadata, don't reconnect.
		if chosen_events.size() > i:
			button.text = chosen_events[i]["name"]
			button.set_meta("event_data", chosen_events[i])
		else:
			button.text = ""
			button.disabled = true


func _on_event_button_pressed(button):
	var event_data = button.get_meta("event_data")
	if event_data:
		print("Event chosen: ", event_data)
		if event_data.type == "battle":
			var enemies = game_manager.enemies
			if enemies.size() > 0:
				var chosen_enemy = enemies[randi() % enemies.size()]
				emit_signal("enemy_chosen", chosen_enemy)
			else:
				print("No enemies available!")
		game_manager.handle_event(event_data)
