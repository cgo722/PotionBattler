extends Node

enum GameState {
	MENU,
	RUNNING,
	CHOOSE_EVENT,
	SHOPPING,
	BATTLE_DRAW_PHASE,
	BATTLE_PLAYER_TURN,
	BATTLE_END_OF_TURN,
	BATTLE_ENEMY_TURN,
	END_RUN
}

@export var possible_events: Array = []
@export var deck_node_path: NodePath = NodePath("Deck")
var deck: Deck
@export var potion_combiner : NodePath
var state: GameState = GameState.MENU
@onready var hand_ui = $HandUi
@onready var tray_ui = $TrayUi
@export var character_resource: Resource
@export var enemies: Array[Resource] = []
var shop_inventory = []
var enemy
var last_turn_was_player := false

func _ready():
	deck = get_node(deck_node_path)
	deck.connect("hand_changed", Callable(hand_ui, "update_hand"))
	show_menu()
	tray_ui.connect("ingredients_selected", Callable(self, "_on_ingredients_selected"))
	if has_node("Situationpicker"):
		$Situationpicker.connect("enemy_chosen", Callable(self, "_on_enemy_chosen"))

func show_menu():
	state = GameState.MENU
	update_ui_visibility()

func start_run():
	state = GameState.RUNNING
	character_resource.current_health = character_resource.starting_health
	deck.clear_all()
	for card_resource in character_resource.starting_deck.keys():
		var count = character_resource.starting_deck[card_resource]
		for i in range(count):
			var card_instance = card_resource.duplicate()
			deck.add_card_to_deck(card_instance)
	deck.shuffle_deck()
	for i in range(deck.hand_limit):
		deck.draw_card()
	hand_ui.update_hand(deck.hand)
	next_phase()

func next_phase():
	match state:
		GameState.RUNNING:
			state = GameState.CHOOSE_EVENT
			update_ui_visibility()
			choose_event()
		GameState.CHOOSE_EVENT:
			pass
		GameState.SHOPPING:
			state = GameState.RUNNING
			update_ui_visibility()
		GameState.BATTLE_DRAW_PHASE:
			state = GameState.BATTLE_PLAYER_TURN
			update_ui_visibility()
			player_turn()
		GameState.BATTLE_PLAYER_TURN, GameState.BATTLE_ENEMY_TURN:
			state = GameState.BATTLE_END_OF_TURN
			update_ui_visibility()
			process_end_of_turn_effects()
		GameState.BATTLE_END_OF_TURN:
			if state == GameState.BATTLE_END_OF_TURN:
				if last_turn_was_player:
					state = GameState.BATTLE_ENEMY_TURN
					update_ui_visibility()
					enemy_turn()
				else:
					state = GameState.BATTLE_DRAW_PHASE
					update_ui_visibility()
					draw_phase()
		GameState.END_RUN:
			show_menu()


func choose_event():
	pass

func start_shop():
	state = GameState.SHOPPING
	update_ui_visibility()
	generate_shop_inventory()

func generate_shop_inventory():
	shop_inventory.clear()
	var all_cards = CardDatabase.get_all_cards()
	for i in range(3):
		var card = all_cards[randi() % all_cards.size()]
		shop_inventory.append(card)

func buy_card(card):
	if character_resource.gold >= card.price:
		character_resource.gold -= card.price
		deck.add_card_to_deck(card.duplicate())
		shop_inventory.erase(card)

func start_battle(enemy_resource):
	if enemy_resource:
		enemy = enemy_resource.duplicate(true)
	state = GameState.BATTLE_DRAW_PHASE
	update_ui_visibility()
	draw_phase()

func draw_phase():
	deck.draw_hand()
	hand_ui.update_hand(deck.hand)

func player_turn():
	last_turn_was_player = true
	process_burn(character_resource)
	deck.draw_hand()
	hand_ui.update_hand(deck.hand)

func enemy_turn():
	last_turn_was_player = false
	process_burn(enemy)
	process_poison(enemy)
	if character_resource.current_health <= 0:
		state = GameState.END_RUN
		update_ui_visibility()
		end_run()
		return
	next_phase()

func end_run():
	pass

func _on_ingredients_selected(ingredients: Array):
	var combiner_node = get_node(potion_combiner)
	var result = combiner_node.combine_ingredients(ingredients)
	if result.has("damage"):
		enemy.current_health -= result.damage
	if result.has("burn"):
		enemy.burn += result.burn
	if result.has("poison"):
		enemy.poison += result.poison
	print("Enemy health after potion:", enemy.current_health) # Debug print
	enemy_turn()

func get_possible_events() -> Array:
	return possible_events.duplicate()

func update_ui_visibility():
	var menu_ui = $MainMenu if has_node("MainMenu") else null
	var hand_ui_node = $HandUi if has_node("HandUi") else null
	var tray_ui_node = $TrayUi if has_node("TrayUi") else null
	var shop_ui = $ShopUi if has_node("ShopUi") else null
	var event_ui = $EventUi if has_node("EventUi") else null
	var situation_picker = $Situationpicker if has_node("Situationpicker") else null

	match state:
		GameState.MENU:
			if menu_ui: menu_ui.visible = true
			if hand_ui_node: hand_ui_node.visible = false
			if tray_ui_node: tray_ui_node.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.RUNNING:
			if menu_ui: menu_ui.visible = false
			if hand_ui_node: hand_ui_node.visible = false
			if tray_ui_node: tray_ui_node.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.CHOOSE_EVENT:
			if menu_ui: menu_ui.visible = false
			if hand_ui_node: hand_ui_node.visible = false
			if tray_ui_node: tray_ui_node.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = true
			if situation_picker: situation_picker.visible = true
		GameState.SHOPPING:
			if menu_ui: menu_ui.visible = false
			if hand_ui_node: hand_ui_node.visible = false
			if tray_ui_node: tray_ui_node.visible = false
			if shop_ui: shop_ui.visible = true
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.BATTLE_DRAW_PHASE, GameState.BATTLE_PLAYER_TURN, GameState.BATTLE_ENEMY_TURN:
			if menu_ui: menu_ui.visible = false
			if hand_ui_node: hand_ui_node.visible = true
			if tray_ui_node: tray_ui_node.visible = true
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.END_RUN:
			if menu_ui: menu_ui.visible = false
			if hand_ui_node: hand_ui_node.visible = false
			if tray_ui_node: tray_ui_node.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false

func handle_event(event_data):
	if event_data.type == "shop":
		state = GameState.SHOPPING
	elif event_data.type == "battle":
		state = GameState.BATTLE_DRAW_PHASE
	else:
		state = GameState.RUNNING
	update_ui_visibility()
	next_phase()

func _on_enemy_chosen(enemy_resource):
	start_battle(enemy_resource)

func process_burn(target):
	if target.burn > 0:
		target.current_health -= target.burn
		target.burn = max(target.burn - target.burn_strength, 0)

func process_poison(target):
	if target.poison > 0:
		target.current_health -= target.poison

func process_end_of_turn_effects():
	if last_turn_was_player:
		process_burn(character_resource)
		process_poison(character_resource)
	else:
		process_burn(enemy)
		process_poison(enemy)

	print("Enemy health:", enemy.current_health, "Burn:", enemy.burn, "Poison:", enemy.poison)
	print("Player health:", character_resource.current_health, "Burn:", character_resource.burn, "Poison:", character_resource.poison)

	# Add a small buffer delay
	var delay_timer := Timer.new()
	delay_timer.one_shot = true
	delay_timer.wait_time = 1.0
	add_child(delay_timer)
	delay_timer.start()
	await delay_timer.timeout
	delay_timer.queue_free()

	next_phase()
