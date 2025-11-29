extends HBoxContainer

signal card_selected(card_ui_instance)

@export var card_ui_scene: PackedScene
@export var max_hand_size: int = 5

func update_hand(hand: Array):
	# Clear old cards
	for child in get_children():
		child.queue_free()
	
	# Instantiate and set up new cards
	for i in range(min(hand.size(), max_hand_size)):
		var card = hand[i]
		var card_ui = card_ui_scene.instantiate()
		card_ui.setup(card)
		card_ui.connect("card_clicked", Callable(self, "_on_card_clicked"))
		add_child(card_ui)

func _on_card_clicked(card_ui_instance):
	# When a card is clicked, just pass the event up to the game manager.
	emit_signal("card_selected", card_ui_instance)