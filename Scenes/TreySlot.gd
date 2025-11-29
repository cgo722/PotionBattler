extends Button

var card: CardResource = null

func set_card(card_resource: CardResource):
    card = card_resource
    set_meta("card", card)
    modulate = Color(1, 1, 1)
    for child in get_children():
        child.queue_free()
    var label = Label.new()
    label.text = card.card_name
    add_child(label)