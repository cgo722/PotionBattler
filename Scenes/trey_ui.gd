extends HBoxContainer

@export var hand_ui_path: NodePath # Set this to your HandUi node in the editor
var slots: Array = []
signal ingredients_selected(ingredients: Array)

func _ready():
    slots = [get_node("Slot0"), get_node("Slot1"), get_node("Slot2")]
    for slot in slots:
        slot.connect("pressed", Callable(self, "_on_slot_pressed").bind(slot))
    get_node("VBoxContainer/CombineButton").connect("pressed", Callable(self, "on_combine_pressed"))

func add_card_to_tray(card: CardResource) -> bool:
    for slot in slots:
        if not slot.has_meta("card") or slot.get_meta("card") == null:
            slot.set_meta("card", card)
            slot.modulate = Color(1, 1, 1)
            for child in slot.get_children():
                child.queue_free()
            var label = Label.new()
            label.text = card.card_name
            slot.add_child(label)
            return true
    return false

func _on_slot_pressed(slot):
    var card = slot.get_meta("card")
    if card:
        var hand_ui = get_node(hand_ui_path)
        var deck = get_tree().get_root().get_node("Gamemanager").deck
        if card not in deck.hand:
            deck.hand.append(card)
            hand_ui.update_hand(deck.hand)
        slot.set_meta("card", null)
        for child in slot.get_children():
            child.queue_free()
        slot.modulate = Color(0.5, 0.5, 0.5)

func clear_tray():
    for slot in slots:
        slot.set_meta("card", null)
        for child in slot.get_children():
            child.queue_free()
        slot.modulate = Color(0.5, 0.5, 0.5)

func on_combine_pressed():
    var ingredients: Array = []
    var deck = get_tree().get_root().get_node("Gamemanager").deck
    for slot in slots:
        var card = slot.get_meta("card")
        if card:
            ingredients.append(card)
            deck.discard_card(card)
    if ingredients.size() > 2:
        emit_signal("ingredients_selected", ingredients)
        clear_tray()

