extends Button

var card: CardResource = null

func _can_drop_data(_pos, data):
    return typeof(data) == TYPE_OBJECT and data is CardResource

func _drop_data(_pos, data):
    set_card(data)

func set_card(card_resource: CardResource):
    card = card_resource
    set_meta("card", card)
    modulate = Color(1, 1, 1)
    for child in get_children():
        child.queue_free()
    var label = Label.new()
    label.text = card.card_name
    add_child(label)