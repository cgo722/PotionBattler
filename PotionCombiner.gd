extends Node

# Example: special recipes by card_name order
var special_recipes = {
	["Mandrake", "Nightshade", "Moonwater"]: {"effect": "Invisibility", "value": 50}
}

func combine_ingredients(ingredients: Array) -> Array:
	var tag_totals := {}
	var tag_counts := {}
	var ingredient_names := []
	
	for ingredient in ingredients:
		ingredient_names.append(ingredient.card_name)
		for tag in ingredient.tags:
			var tag_value := 0
			for effect in ingredient.effects:
				if effect.effect_type == tag:
					tag_value += effect.value
			if tag_value > 0:
				tag_totals[tag] = tag_totals.get(tag, 0) + tag_value
				tag_counts[tag] = tag_counts.get(tag, 0) + 1
	
	# Multiply effects for tags with multiple ingredients
	for tag in tag_totals.keys():
		if tag_counts[tag] > 1:
			tag_totals[tag] *= tag_counts[tag]
	
	# Check for special recipes (exact order)
	for recipe in special_recipes.keys():
		if ingredient_names == recipe:
			var special_effect := CardEffect.new()
			special_effect.effect_type = special_recipes[recipe]["effect"]
			special_effect.value = special_recipes[recipe]["value"]
			return [special_effect]

	var final_effects: Array = []
	for tag in tag_totals.keys():
		var effect := CardEffect.new()
		effect.effect_type = tag
		effect.value = tag_totals[tag]
		final_effects.append(effect)

	return final_effects

func apply_card_effect(card: CardResource, target: Node):
	for effect in card.effects:
		match effect.effect_type:
			"burn":
				target.apply_burn(effect.value)
			"damage":
				target.take_damage(effect.value)
			"heal":
				target.heal(effect.value)
			"poison":
				target.apply_poison(effect.value)
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
