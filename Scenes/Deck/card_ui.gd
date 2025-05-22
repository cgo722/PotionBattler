# CardUI.gd
extends Button

var card: CardResource
@export var tray_ui_path: NodePath = NodePath("/root/Gamemanager/TrayUi") # Adjust path as needed

func setup(card_resource: CardResource):
	card = card_resource
	text = card.card_name
	
func _get_drag_data(_pos):
	var drag_preview = duplicate()
	set_drag_preview(drag_preview)
	return card

func _pressed():
	var tray_ui = get_node(tray_ui_path)
	if tray_ui and tray_ui.add_card_to_tray(card):
		var deck = get_tree().get_root().get_node("Gamemanager").deck
		# Remove the exact instance from hand
		deck.hand.erase(card)
		var hand_ui = get_tree().get_root().get_node("Gamemanager").hand_ui
		hand_ui.update_hand(deck.hand)
		queue_free()
	else:
		print("Tray is full! Cannot add card.")
