extends Node

enum GameState {
    MENU,
    RUNNING,
    CHOOSE_EVENT,
    SHOPPING,
    BATTLE_DRAW_PHASE,
    BATTLE_PLAYER_TURN,
    BATTLE_ENEMY_TURN,
    END_RUN
}

@export var deck_node_path: NodePath = NodePath("Deck")
var deck: Deck

@export var potion_combiner : NodePath # Adjust path as needed

var state: GameState = GameState.MENU
@onready var hand_ui = $HandUi
@onready var tray_ui = $TrayUi

@export var character_resource: Resource # Assign in the editor

func _ready():
    deck = get_node(deck_node_path)
    show_menu()
    tray_ui.connect("ingredients_selected", Callable(self, "_on_ingredients_selected"))

func show_menu():
    state = GameState.MENU
    update_ui_visibility()
    print("Main Menu")
    # Show menu UI here

func start_run():
    state = GameState.RUNNING
    character_resource.current_health = character_resource.starting_health
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
    print("Run started! Hand: %s" % [deck.hand])
    print("Starting deck:", character_resource.starting_deck)
    next_phase()

func next_phase():
    match state:
        GameState.RUNNING:
            # Decide what comes next: event, shop, or battle
            # For now, let's go to CHOOSE_EVENT as an example
            state = GameState.CHOOSE_EVENT
            update_ui_visibility()
            choose_event()
        GameState.CHOOSE_EVENT:
            # After event is chosen, transition to SHOPPING, BATTLE, or back to RUNNING
            pass # Implement event choice logic
        GameState.SHOPPING:
            # After shopping, return to RUNNING or next event
            state = GameState.RUNNING
            update_ui_visibility()
        GameState.BATTLE_DRAW_PHASE:
            state = GameState.BATTLE_PLAYER_TURN
            update_ui_visibility()
            player_turn()
        GameState.BATTLE_PLAYER_TURN:
            state = GameState.BATTLE_ENEMY_TURN
            update_ui_visibility()
            enemy_turn()
        GameState.BATTLE_ENEMY_TURN:
            # End battle or loop back to draw phase
            # For example, after enemy turn, go back to draw phase or end battle
            state = GameState.BATTLE_DRAW_PHASE
            update_ui_visibility()
            draw_phase()
        GameState.END_RUN:
            show_menu()

func choose_event():
    print("Choosing event...")
    # Show event UI, let player pick, then transition to next state
    # Example: state = GameState.SHOPPING or state = GameState.BATTLE_DRAW_PHASE
    # Call update_ui_visibility() and next_phase() as needed

func start_shop():
    state = GameState.SHOPPING
    update_ui_visibility()
    print("Shopping phase started.")
    # Show shop UI, handle purchases, then call next_phase() when done

func start_battle():
    state = GameState.BATTLE_DRAW_PHASE
    update_ui_visibility()
    draw_phase()

func draw_phase():
    print("Draw Phase")
    deck.draw_hand()
    hand_ui.update_hand(deck.hand)
    print("Hand after draw phase:", deck.hand)
    # Wait for player to continue, or call next_phase() if automatic

func player_turn():
    print("Player Turn")
    hand_ui.update_hand(deck.hand)
    # Implement player actions here
    # After player finishes, call next_phase()

func enemy_turn():
    print("Enemy Turn")
    # Implement enemy actions here
    # After enemy finishes, call next_phase()

func end_run():
    print("End of Run")
    # Show end screen or summary

func _on_ingredients_selected(ingredients: Array):
    var combiner_node = get_node(potion_combiner)
    var result = combiner_node.combine_ingredients(ingredients)
    print("Potion result: ", result)
    next_phase()

func update_ui_visibility():
    var menu_ui = $MainMenu if has_node("MainMenu") else null
    var hand_ui_node = $HandUi if has_node("HandUi") else null
    var tray_ui_node = $TrayUi if has_node("TrayUi") else null
    var shop_ui = $ShopUi if has_node("ShopUi") else null
    var event_ui = $EventUi if has_node("EventUi") else null

    match state:
        GameState.MENU:
            if menu_ui: menu_ui.visible = true
            if hand_ui_node: hand_ui_node.visible = false
            if tray_ui_node: tray_ui_node.visible = false
            if shop_ui: shop_ui.visible = false
            if event_ui: event_ui.visible = false
        GameState.RUNNING:
            if menu_ui: menu_ui.visible = false
            if hand_ui_node: hand_ui_node.visible = false
            if tray_ui_node: tray_ui_node.visible = false
            if shop_ui: shop_ui.visible = false
            if event_ui: event_ui.visible = false
        GameState.CHOOSE_EVENT:
            if menu_ui: menu_ui.visible = false
            if hand_ui_node: hand_ui_node.visible = false
            if tray_ui_node: tray_ui_node.visible = false
            if shop_ui: shop_ui.visible = false
            if event_ui: event_ui.visible = true
        GameState.SHOPPING:
            if menu_ui: menu_ui.visible = false
            if hand_ui_node: hand_ui_node.visible = false
            if tray_ui_node: tray_ui_node.visible = false
            if shop_ui: shop_ui.visible = true
            if event_ui: event_ui.visible = false
        GameState.BATTLE_DRAW_PHASE, GameState.BATTLE_PLAYER_TURN, GameState.BATTLE_ENEMY_TURN:
            if menu_ui: menu_ui.visible = false
            if hand_ui_node: hand_ui_node.visible = true
            if tray_ui_node: tray_ui_node.visible = true
            if shop_ui: shop_ui.visible = false
            if event_ui: event_ui.visible = false
        GameState.END_RUN:
            if menu_ui: menu_ui.visible = false
            if hand_ui_node: hand_ui_node.visible = false
            if tray_ui_node: tray_ui_node.visible = false
            if shop_ui: shop_ui.visible = false
            if event_ui: event_ui.visible = false
