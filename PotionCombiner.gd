extends Node

# Example: special recipes by card_name order
var special_recipes = {
	["Mandrake", "Nightshade", "Moonwater"]: {"effect": "Invisibility", "value": 50}
}

func combine_ingredients(ingredients: Array) -> Array:
	var effect_totals := {}
	var ingredient_names := []

	for ingredient in ingredients:
		ingredient_names.append(ingredient.card_name)
		for effect in ingredient.effects:
			# Add up the values for each effect type
			effect_totals[effect.effect_type] = effect_totals.get(effect.effect_type, 0) + effect.value

	# Check for special recipes (exact order)
	# This part can stay if you want to have specific named combinations override the default logic.
	for recipe in special_recipes.keys():
		if ingredient_names == recipe:
			var special_effect := CardEffect.new()
			special_effect.effect_type = special_recipes[recipe]["effect"]
			special_effect.value = special_recipes[recipe]["value"]
			return [special_effect]
	
	var final_effects: Array = []
	for effect_type in effect_totals.keys():
		var effect := CardEffect.new()
		effect.effect_type = effect_type
		effect.value = effect_totals[effect_type]
		# The target will be determined by Gamemanager, so we don't need to set it here.
		final_effects.append(effect)
	
	return final_effects

func apply_card_effect(card: CardResource, target: Node):
	for effect in card.effects:
		match effect.effect_type:
			"ward": # was burn
				target.ward += effect.value
			"damage":
				target.take_damage(effect.value)
			"heal":
				target.heal(effect.value)
			"bless": # was poison
				target.bless += effect.value
			"armor":
				target.add_armor(effect.value)
			"chaos":
				target.apply_chaos(effect.value)
			"draw":
				target.draw_cards(effect.value)
			"discard":
				target.discard_cards(effect.value)
			_:
				print("Unknown effect type: %s" % effect.effect_type)
