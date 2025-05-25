extends Panel

signal card_clicked(card_resource)

var card_resource

func setup(card):
	card_resource = card
	$CardNameLabel.text = card.card_name
	# Set up visuals, etc.

func _get_drag_data(_pos):
	var preview = duplicate()
	set_drag_preview(preview)
	return {"card_resource": card_resource}

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_clicked", card_resource)
