extends Button

func _get_drag_data(_pos):
    var drag_preview = duplicate() # Or create a custom preview node
    set_drag_preview(drag_preview)
    var card_data = {} # Replace with actual card data as needed
    return card_data