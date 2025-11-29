extends Panel

signal card_clicked(card_ui_instance)

@export var animation_curve: Curve

var card_resource

# Animation state
var is_animating = false
var animation_progress = 0.0
var start_pos: Vector2
var target_pos: Vector2
var start_scale: Vector2
var end_scale: Vector2 # New variable for fly_to_hand

func setup(card):
	card_resource = card
	$CardNameLabel.text = card.card_name
	# Set up other visuals

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_clicked", self)

func _process(_delta):
	if is_animating:
		var t = animation_progress
		# If a curve is provided, use it to sample the interpolation factor
		if animation_curve:
			t = animation_curve.sample(animation_progress)
			print("Using curve. animation_progress: ", animation_progress, ", sampled t: ", t) # Debug print
		else:
			print("No animation_curve set. animation_progress: ", animation_progress) # Debug print
		
		# Lerp (linearly interpolate) position and scale based on the factor 't'
		global_position = start_pos.lerp(target_pos, t)
		scale = start_scale.lerp(end_scale, t) # Use end_scale here

func fly_to(target: Vector2):
	# Set up animation parameters
	is_animating = true
	animation_progress = 0.0 # Reset progress
	start_pos = global_position
	target_pos = target
	start_scale = scale
	end_scale = Vector2.ZERO # Card disappears
	
	# Create a tween to drive the animation_progress property
	var tween = create_tween()
	
	# Calculate duration based on distance to keep speed consistent
	var distance = global_position.distance_to(target_pos)
	var duration = clamp(distance / 2000.0, 0.2, 0.4) # pixels/sec
	
	# Animate the progress value from 0.0 to 1.0 linearly. The curve will handle the easing.
	tween.tween_property(self, "animation_progress", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	
	# Wait for the animation to finish
	await tween.finished
	
	# Clean up
	is_animating = false
	queue_free()

func fly_to_hand(target: Vector2, final_scale: Vector2):
	# Set up animation parameters
	is_animating = true
	animation_progress = 0.0 # Reset progress
	start_pos = global_position
	target_pos = target
	start_scale = scale
	end_scale = final_scale # Card returns to normal scale
	
	# Create a tween to drive the animation_progress property
	var tween = create_tween()
	
	# Calculate duration based on distance to keep speed consistent
	var distance = global_position.distance_to(target_pos)
	var duration = clamp(distance / 2000.0, 0.2, 0.4) # pixels/sec
	
	# Animate the progress value from 0.0 to 1.0 linearly. The curve will handle the easing.
	tween.tween_property(self, "animation_progress", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
	
	# Wait for the animation to finish
	await tween.finished
	
	# Clean up
	is_animating = false
	queue_free()

func get_animation_curve() -> Curve:
	return animation_curve

