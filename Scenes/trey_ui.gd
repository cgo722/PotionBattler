extends HBoxContainer

# This UI component is now purely visual. The GameManager will manage the state.

signal slot_clicked(slot_index)

var slots: Array = []

func _ready():
	slots = [get_node("Slot0"), get_node("Slot1"), get_node("Slot2")]
	for i in range(slots.size()):
		slots[i].connect("pressed", Callable(self, "_on_slot_pressed").bind(i))
	# The GameManager will now handle the combine button press.

func _on_slot_pressed(slot_index: int):
	emit_signal("slot_clicked", slot_index)
func update_display(cards_in_tray: Array):
	"""
	Updates the visual display of the tray based on the cards provided.
	"""
	for i in range(slots.size()):
		var slot = slots[i]
		# Clear previous content from the slot
		for child in slot.get_children():
			child.queue_free()
		
		if i < cards_in_tray.size():
			# If there is a card for this slot, display it.
			var label = Label.new()
			label.text = cards_in_tray[i].card_name
			slot.add_child(label)
			slot.modulate = Color(1, 1, 1) # Make it look active
		else:
			# Otherwise, make it look empty.
			slot.modulate = Color(0.5, 0.5, 0.5)

func get_next_empty_slot_global_position(cards_in_tray_count: int):
	"""
	Returns the global position of the center of the next empty slot.
	Returns null if the tray is full.
	"""
	if cards_in_tray_count < slots.size():
		var next_slot = slots[cards_in_tray_count]
		return next_slot.global_position + next_slot.size / 2
	return null
