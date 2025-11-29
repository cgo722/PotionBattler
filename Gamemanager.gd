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
@export var card_ui_scene: PackedScene
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
var enemy_deck: Deck
var last_turn_was_player := false
var tray_cards: Array = []

#region Initialization and Run Management

func _ready():
	deck = get_node(deck_node_path)
	deck.connect("hand_changed", Callable(hand_ui, "update_hand"))
	show_menu()
	
	# Connect signals for the new card interaction flow
	hand_ui.connect("card_selected", Callable(self, "_on_hand_card_selected"))
	tray_ui.connect("slot_clicked", Callable(self, "_on_tray_slot_clicked"))
	tray_ui.get_node("VBoxContainer/CombineButton").connect("pressed", Callable(self, "_on_combine_button_pressed"))

	if situation_picker:
		situation_picker.connect("enemy_chosen", Callable(self, "_on_enemy_chosen"))

func show_menu():
	state = GameState.MENU
	update_ui_visibility()

func start_run():
	state = GameState.RUNNING
	character_resource.current_health = character_resource.starting_health
	tray_cards.clear()
	tray_ui.update_display([])
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
			next_phase()
		GameState.BATTLE_PLAYER_TURN:
			end_turn()
		GameState.BATTLE_ENEMY_TURN:
			end_turn()
		GameState.END_RUN:
			show_menu()

func choose_event():
	if situation_picker:
		situation_picker.randomize_buttons()

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
	print("\n--- BATTLE START ---")
	if enemy_resource:
		enemy = enemy_resource.duplicate(true)
		print("Enemy: ", enemy.name)

	tray_cards.clear()
	tray_ui.update_display([])

	# Create and populate the enemy's deck
	enemy_deck = Deck.new()
	if enemy and enemy.starting_deck:
		var enemy_card_names = []
		for card in enemy.starting_deck.keys(): enemy_card_names.append(card.card_name)
		print("Enemy deck contains: ", enemy_card_names)

		for card_resource in enemy.starting_deck.keys():
			var count = enemy.starting_deck[card_resource]
			for i in range(count):
				var card_instance = card_resource.duplicate()
				enemy_deck.add_card_to_deck(card_instance)
		enemy_deck.shuffle_deck()

	state = GameState.BATTLE_PLAYER_TURN
	update_ui_visibility()
	player_turn()

func draw_phase():
	deck.draw_hand()
	hand_ui.update_hand(deck.hand)

func player_turn():
	print("\n--- PLAYER'S TURN ---")
	last_turn_was_player = true
	print("Player HP: ", character_resource.current_health, " | Armor: ", character_resource.aromor, " | Burn: ", character_resource.burn, " | Poison: ", character_resource.poison)
	print("Enemy HP: ", enemy.current_health, " | Armor: ", enemy.aromor, " | Burn: ", enemy.burn, " | Poison: ", enemy.poison)

	apply_burn_damage(character_resource)
	apply_poison_damage(character_resource)
	if character_resource.current_health <= 0:
		state = GameState.END_RUN
		update_ui_visibility()
		end_run()
		return

	deck.draw_hand()
	var hand_names = []
	for card in deck.hand: hand_names.append(card.card_name)
	print("Player drew: ", hand_names)
	hand_ui.update_hand(deck.hand)

func enemy_turn():
	print("\n--- ENEMY'S TURN ---")
	last_turn_was_player = false
	print("Player HP: ", character_resource.current_health, " | Armor: ", character_resource.aromor, " | Burn: ", character_resource.burn, " | Poison: ", character_resource.poison)
	print("Enemy HP: ", enemy.current_health, " | Armor: ", enemy.aromor, " | Burn: ", enemy.burn, " | Poison: ", enemy.poison)

	apply_burn_damage(enemy)
	apply_poison_damage(enemy)
	if enemy.current_health <= 0:
		state = GameState.RUNNING
		update_ui_visibility()
		enemy_deck = null # Clean up enemy deck
		next_phase()
		return

	# Enemy AI
	if enemy_deck:
		# 1. Draw cards (e.g., up to 3)
		enemy_deck.hand.clear() # Clear from previous turn
		for i in range(3):
			enemy_deck.draw_card()
		
		var enemy_hand = enemy_deck.hand
		if !enemy_hand.is_empty():
			var card_names = []
			for c in enemy_hand: card_names.append(c.card_name)
			print("Enemy uses: ", card_names)

			# 2. Combine cards
			var combiner_node = get_node(potion_combiner)
			var result = combiner_node.combine_ingredients(enemy_hand)

			# 3. Apply effects
			if result is Array:
				for effect in result:
					var target = character_resource # Default target is the player
					if effect.target == "player": # "player" in the effect resource means self-cast
						target = enemy
					
					match effect.effect_type:
						"damage":
							if target == character_resource:
								target.current_health -= effect.value
								print("Enemy deals ", effect.value, " damage!")
						"burn":
							if target == character_resource:
								target.burn += effect.value
								print("Enemy applies ", effect.value, " burn!")
						"poison":
							if target == character_resource:
								target.poison += effect.value
								print("Enemy applies ", effect.value, " poison!")
						"heal":
							if target == enemy:
								target.current_health += effect.value
								print("Enemy heals for ", effect.value)
						"armor":
							if target == enemy:
								target.aromor += effect.value
								print("Enemy gains ", effect.value, " armor")
						_:
							print("Unknown effect type from enemy potion:", effect.effect_type)
			else:
				print("Enemy combination failed.")

			# 4. Discard hand
			for card in enemy_hand:
				enemy_deck.discard.append(card)
			enemy_deck.hand.clear()

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

func _on_hand_card_selected(card_ui):
	# This function is called when a card in the hand is clicked.
	
	# 1. Check if the tray is already full.
	if tray_cards.size() >= 3:
		print("Tray is full!")
		return

	var card_resource = card_ui.card_resource
	
	# 2. Get the target position for the animation from the tray UI.
	var target_pos = tray_ui.get_next_empty_slot_global_position(tray_cards.size())
	
	if target_pos:
		# Store original global position before reparenting
		var original_global_pos = card_ui.global_position

		# 3. Reparent the card so it doesn't get deleted by the hand_ui update.
		card_ui.get_parent().remove_child(card_ui)
		get_tree().root.add_child(card_ui)
		card_ui.global_position = original_global_pos # Restore global position after reparenting

		# 4. Update the hand data model and the hand UI.
		deck.hand.erase(card_resource)
		hand_ui.update_hand(deck.hand)
		
		# 5. Animate the card's movement and wait for it to finish.
		await card_ui.fly_to(target_pos)
		
		# 6. Now that the card has arrived, update the tray data model and UI.
		tray_cards.append(card_resource)
		tray_ui.update_display(tray_cards)

func _on_tray_slot_clicked(slot_index: int):
	# Check if there's a card in that slot to remove.
	if slot_index < tray_cards.size():
		var card_to_return = tray_cards[slot_index] # Get the card without removing it yet
		
		# 1. Get start and end positions for the animation
		var start_pos = tray_ui.slots[slot_index].global_position + tray_ui.slots[slot_index].size / 2
		var target_pos = hand_ui.global_position + hand_ui.size / 2 # Animate to center of hand
		
		# 2. Instantiate a temporary card for the animation
		if card_ui_scene:
			var flying_card = card_ui_scene.instantiate()
			flying_card.setup(card_to_return)
			# Copy the animation curve from the original CardUI scene
			if card_ui_scene.resource_path and card_ui_scene.resource_path.ends_with(".tscn"):
				var loaded_scene = load(card_ui_scene.resource_path)
				if loaded_scene is PackedScene:
					var root_node = loaded_scene.instantiate()
					# Check for a child node to ensure it's a CardUI and has the property
					if root_node is Control and root_node.has_node("CardNameLabel") and root_node.has_method("get_animation_curve"): 
						flying_card.animation_curve = root_node.get_animation_curve()
					root_node.queue_free() # Free the temporary instance
			
			get_tree().root.add_child(flying_card)
			flying_card.global_position = start_pos
			
			# Animate the temporary card. It will queue_free itself when done.
			# Animate to a scale of 1.0 (normal size)
			flying_card.fly_to_hand(target_pos, Vector2(1.0, 1.0))
		
		# 3. Update data models
		tray_cards.pop_at(slot_index)
		deck.hand.append(card_to_return)
		
		# 4. Update UIs
		tray_ui.update_display(tray_cards)
		hand_ui.update_hand(deck.hand)

func _on_combine_button_pressed():
	if tray_cards.size() < 3: # Minimum of 3 ingredients to combine.
		print("Not enough ingredients to combine!")
		return
	
	# Discard the cards that were used for combining.
	for card in tray_cards:
		deck.discard.append(card)
	
	# Trigger the combination logic and apply the effects.
	_combine_and_apply_effects(tray_cards)
	
	# Clear the tray data and update its display.
	tray_cards.clear()
	tray_ui.update_display(tray_cards)

func _combine_and_apply_effects(ingredients: Array):
	var ingredient_names = []
	for ing in ingredients: ingredient_names.append(ing.card_name)
	print("Player combines: ", ingredient_names)

	var combiner_node = get_node(potion_combiner)
	var result = combiner_node.combine_ingredients(ingredients)

	if result is Array:
		print("Potion Result: ", result)
		for effect in result:
			var target = enemy
			var target_name = enemy.name
			if effect.target == "player":
				target = character_resource
				target_name = character_resource.name

			print("Applying effect '", effect.effect_type, "' (value: ", effect.value, ") to ", target_name)
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
	if event_data and event_data.has_method("execute"):
		event_data.execute(self)
	else:
		print("Error: Event data is not a valid event resource or does not have an execute method.")
		# Fallback to prevent getting stuck
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
		print("Ending player's turn.")
		state = GameState.BATTLE_ENEMY_TURN
		update_ui_visibility()
		enemy_turn()
	else:
		print("Ending enemy's turn.")
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
