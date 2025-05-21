extends Node2D

enum CustomSceneState {
	SELECTION,
	FIGHT,
	RANDOMENCOUNTER,
	SHOP
}

@export var scene_state: CustomSceneState = CustomSceneState.SELECTION
@export var force_fight: bool = false # Set this to true for guaranteed fight rounds
@export var option_buttons: Array[Button] # Assign your 3 buttons in the editor

var available_options: Array = []

func _ready():
	if scene_state == CustomSceneState.SELECTION:
		_setup_selection_options()
		_show_selection_ui()
	elif scene_state == CustomSceneState.FIGHT:
		_start_fight_encounter()
	elif scene_state == CustomSceneState.RANDOMENCOUNTER:
		_start_random_encounter()
	elif scene_state == CustomSceneState.SHOP:
		_start_shop_encounter()

func _setup_selection_options():
	if force_fight:
		available_options = [CustomSceneState.FIGHT, CustomSceneState.FIGHT, CustomSceneState.FIGHT]
	else:
		available_options = []
		var types = [
		CustomSceneState.FIGHT,
		CustomSceneState.RANDOMENCOUNTER,
		CustomSceneState.SHOP
		]
		for i in range(3):
			var random_type = types[randi() % types.size()]
			available_options.append(random_type)

	
func _show_selection_ui():
	# Hide all buttons first
	for btn in option_buttons:
		btn.visible = false
		# Disconnect all pressed signal connections for this button
		for conn in btn.pressed.get_connections():
			btn.pressed.disconnect(conn["callable"])

	# Show and configure buttons based on available_options
	for i in range(available_options.size()):
		var option = available_options[i]
		var btn = option_buttons[i]
		btn.visible = true
		match option:
			CustomSceneState.FIGHT:
				btn.text = "Fight"
				btn.pressed.connect(_on_fight_pressed)
			CustomSceneState.RANDOMENCOUNTER:
				btn.text = "Random Event"
				btn.pressed.connect(_on_random_pressed)
			CustomSceneState.SHOP:
				btn.text = "Shop"
				btn.pressed.connect(_on_shop_pressed)

func _on_fight_pressed():
	scene_state = CustomSceneState.FIGHT
	_start_fight_encounter()

func _on_random_pressed():
	scene_state = CustomSceneState.RANDOMENCOUNTER
	_start_random_encounter()

func _on_shop_pressed():
	scene_state = CustomSceneState.SHOP
	_start_shop_encounter()

func _start_fight_encounter():
	print("Fight encounter started.")

func _start_random_encounter():
	print("Random encounter started.")

func _start_shop_encounter():
	print("Shop encounter started.")
