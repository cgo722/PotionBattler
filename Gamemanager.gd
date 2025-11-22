extends Node

enum GameState {
	MENU,
	RUNNING,
	CHOOSE_EVENT,
	SHOPPING,
	BATTLE_PLAYER_TURN,
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
@onready var menu_ui = $MainMenu if has_node("MainMenu") else null
@onready var shop_ui = $ShopUi if has_node("ShopUi") else null
@onready var event_ui = $EventUi if has_node("EventUi") else null
@onready var situation_picker = $Situationpicker if has_node("Situationpicker") else null

@export var character_resource: Resource
@export var enemies: Array[Resource] = []
var shop_inventory = []
var enemy
var last_turn_was_player := false

#region Initialization and Run Management

func _ready():
	deck = get_node(deck_node_path)
	deck.connect("hand_changed", Callable(hand_ui, "update_hand"))
	show_menu()
	tray_ui.connect("ingredients_selected", Callable(self, "_on_ingredients_selected"))
	if situation_picker:
		situation_picker.connect("enemy_chosen", Callable(self, "_on_enemy_chosen"))

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

# endregion

# region Game State and Phase Management

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
		GameState.BATTLE_PLAYER_TURN:
			end_turn()
		GameState.BATTLE_ENEMY_TURN:
			end_turn()
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
	state = GameState.BATTLE_PLAYER_TURN
	update_ui_visibility()
	player_turn()

func draw_phase():
	deck.draw_hand()
	hand_ui.update_hand(deck.hand)

func player_turn():
	last_turn_was_player = true
	apply_burn_damage(character_resource)
	apply_poison_damage(character_resource)
	if character_resource.current_health <= 0:
		state = GameState.END_RUN
		update_ui_visibility()
		end_run()
		return
	deck.draw_hand()
	hand_ui.update_hand(deck.hand)

func enemy_turn():
	last_turn_was_player = false
	apply_burn_damage(enemy)
	apply_poison_damage(enemy)
	if enemy.current_health <= 0:
		state = GameState.RUNNING # Or some victory state
		update_ui_visibility()
		# TODO: Add rewards, etc.
		end_run()
		return

	# Simple enemy AI: attack for 5 damage
	character_resource.current_health -= 5
	print("Enemy attacks for 5 damage!")

	if character_resource.current_health <= 0:
		state = GameState.END_RUN
		update_ui_visibility()
		end_run()
		return
	
	state = GameState.BATTLE_PLAYER_TURN
	update_ui_visibility()
	player_turn()

func end_run():
	if character_resource.current_health <= 0:
		print("You lose!")
	else:
		print("You win!")
	# For now, just go back to the menu
	show_menu()

# endregion

# region Potion and Event Handling

func _on_ingredients_selected(ingredients: Array):
	var combiner_node = get_node(potion_combiner)
	var result = combiner_node.combine_ingredients(ingredients)

	if result is Array:
		for effect in result:
			var target = enemy
			if effect.target == "player":
				target = character_resource

			match effect.effect_type:
				"damage":
					target.current_health -= effect.value
				"burn":
					target.burn += effect.value
				"poison":
					target.poison += effect.value
				"heal":
					target.current_health += effect.value
				"armor":
					target.aromor += effect.value
				_:
					print("Unknown effect type from potion:", effect.effect_type)
	else:
		print("Invalid potion result:", result)

	end_turn()

func get_possible_events() -> Array:
	return possible_events.duplicate()

func handle_event(event_data):
	if event_data.type == "shop":
		state = GameState.SHOPPING
	elif event_data.type == "battle":
		start_battle(event_data.enemy)
	else:
		state = GameState.RUNNING
	update_ui_visibility()
	next_phase()

func _on_enemy_chosen(enemy_resource):
	start_battle(enemy_resource)

# endregion

# region Status Effects Processing

func apply_burn_damage(target):
	if target.burn > 0:
		target.current_health -= target.burn
		target.burn = max(target.burn - target.burn_strength, 0)

func apply_poison_damage(target):
	if target.poison > 0:
		target.current_health -= target.poison

func end_turn():
	if last_turn_was_player:
		state = GameState.BATTLE_ENEMY_TURN
		update_ui_visibility()
		enemy_turn()
	else:
		state = GameState.BATTLE_PLAYER_TURN
		update_ui_visibility()
		player_turn()

# endregion

# region UI Management

func update_ui_visibility():
	match state:
		GameState.MENU:
			if menu_ui: menu_ui.visible = true
			if hand_ui: hand_ui.visible = false
			if tray_ui: tray_ui.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.RUNNING:
			if menu_ui: menu_ui.visible = false
			if hand_ui: hand_ui.visible = false
			if tray_ui: tray_ui.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.CHOOSE_EVENT:
			if menu_ui: menu_ui.visible = false
			if hand_ui: hand_ui.visible = false
			if tray_ui: tray_ui.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = true
			if situation_picker: situation_picker.visible = true
		GameState.SHOPPING:
			if menu_ui: menu_ui.visible = false
			if hand_ui: hand_ui.visible = false
			if tray_ui: tray_ui.visible = false
			if shop_ui: shop_ui.visible = true
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.BATTLE_PLAYER_TURN, GameState.BATTLE_ENEMY_TURN:
			if menu_ui: menu_ui.visible = false
			if hand_ui: hand_ui.visible = true
			if tray_ui: tray_ui.visible = true
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false
		GameState.END_RUN:
			if menu_ui: menu_ui.visible = false
			if hand_ui: hand_ui.visible = false
			if tray_ui: tray_ui.visible = false
			if shop_ui: shop_ui.visible = false
			if event_ui: event_ui.visible = false
			if situation_picker: situation_picker.visible = false

# endregion
