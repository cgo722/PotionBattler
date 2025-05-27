extends HBoxContainer

@export var card_ui_scene: PackedScene
@export var max_hand_size: int = 5 # Set this to your desired max
@export var tray_ui_path: NodePath # Set this in the editor to the tray UI node

func update_hand(hand: Array):
	# Clear old cards
	for child in get_children():
		child.queue_free()
	# Only show up to max_hand_size cards
	for i in range(min(hand.size(), max_hand_size)):
		var card = hand[i]
		var card_ui = card_ui_scene.instantiate()
		card_ui.setup(card)
		card_ui.connect("card_clicked", Callable(self, "_on_card_clicked"))
		add_child(card_ui)

func add_card_to_hand(card: CardResource):
	if get_child_count() < max_hand_size:
		var card_ui = card_ui_scene.instantiate()
		card_ui.setup(card)
		card_ui.connect("card_clicked", Callable(self, "_on_card_clicked").bind(card))
		add_child(card_ui)
	# Optionally, you can implement a logic to discard the oldest card if the hand is full

func _on_card_clicked(card_resource):
	var tray = get_node(tray_ui_path)
	if tray.add_card_to_tray(card_resource):
		var deck = get_tree().get_root().get_node("Gamemanager").deck
		deck.hand.erase(card_resource)
		update_hand(deck.hand)