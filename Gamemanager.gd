extends Node

enum GameState {
	MENU,
	RUNNING,
	DRAW_PHASE,
	PLAYER_TURN,
	ENEMY_TURN,
	END_RUN
}

@export var deck_node_path: NodePath = NodePath("Deck")
var deck: Deck

var state: GameState = GameState.MENU
@onready var hand_ui = $HandUi

@export var character_resource: Resource # Assign in the editor

func _ready():
	deck = get_node(deck_node_path)
	show_menu()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		match state:
			GameState.MENU:
				start_run()
			GameState.RUNNING:
				# Handle running state
				pass
			GameState.DRAW_PHASE:
				draw_phase()
			GameState.PLAYER_TURN:
				player_turn()
			GameState.ENEMY_TURN:
				enemy_turn()
			GameState.END_RUN:
				end_run()

func show_menu():
	state = GameState.MENU
	print("Main Menu")
	# Show menu UI here


func start_run():
	state = GameState.RUNNING
	deck.clear_all()
	# Add cards from character's starting deck
	for card_name in character_resource.starting_deck.keys():
		var count = character_resource.starting_deck[card_name]
		var card_resource = CardDatabase.get_card_by_name(card_name)
		for i in range(count):
			var card_instance = card_resource.duplicate() # Unique instance for each card
			deck.add_card_to_deck(card_instance)
	deck.shuffle_deck()
	for i in range(deck.hand_limit):
		deck.draw_card()
	hand_ui.update_hand(deck.hand)
	print("Run started! Hand: %s" % deck.hand)
	print("Starting deck:", character_resource.starting_deck)
	next_phase()
	
func next_phase():
	match state:
		GameState.RUNNING:
			state = GameState.DRAW_PHASE
			draw_phase()
		GameState.DRAW_PHASE:
			state = GameState.PLAYER_TURN
			player_turn()
		GameState.PLAYER_TURN:
			state = GameState.ENEMY_TURN
			enemy_turn()
		GameState.ENEMY_TURN:
			state = GameState.END_RUN
			end_run()
		GameState.END_RUN:
			show_menu()

func draw_phase():
	print("Draw Phase")
	var card = deck.draw_card()
	if card:
		print("Drew card: %s" % card.card_name)
	else:
		print("Cannot draw more cards.")
	next_phase()

func player_turn():
	print("Player Turn")
	hand_ui.update_hand(deck.hand)
	# Implement player actions here
	# After player finishes, call next_phase()
	# next_phase()

func enemy_turn():
	print("Enemy Turn")
	# Implement enemy actions here
	# After enemy finishes, call next_phase()
	# next_phase()

func end_run():
	print("End of Run")
	# Show end screen or summary
