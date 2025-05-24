extends Button

var card_resource

func setup(card):
	card_resource = card

func _get_drag_data(_pos):
	var drag_preview = duplicate()
	set_drag_preview(drag_preview)
	var card_data = {
		"card_resource": card_resource # Make sure this is your CardResource
	}
	return card_data