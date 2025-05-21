extends HBoxContainer

@export var card_ui_scene: PackedScene
@export var max_hand_size: int = 5 # Set this to your desired max

func update_hand(hand: Array):
	# Clear old cards
	for child in get_children():
		child.queue_free()
	# Only show up to max_hand_size cards
	for i in range(min(hand.size(), max_hand_size)):
		var card = hand[i]
		var card_ui = card_ui_scene.instantiate()
		card_ui.setup(card)
		add_child(card_ui)

func add_card_to_hand(card: CardResource):
	if get_child_count() < max_hand_size:
		var card_ui = card_ui_scene.instantiate()
		card_ui.setup(card)
		add_child(card_ui)
	else:
		print("Hand is full! Cannot add more cards.")
	# Optionally, you can implement a logic to discard the oldest card if the hand is full