# In CardUI.gd
extends Panel # or Control

var card_resource

func setup(card):
    card_resource = card
    $CardNameLabel.text = card.card_name
    # Set up visuals, etc.

func _get_drag_data(_pos):
    var preview = duplicate()
    set_drag_preview(preview)
    return {"card_resource": card_resource}
