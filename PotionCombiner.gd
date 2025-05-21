extends Node

# Example: special recipes by card_name order
var special_recipes = {
    ["Mandrake", "Nightshade", "Moonwater"]: {"effect": "Invisibility", "value": 50}
}

func combine_ingredients(ingredients: Array[CardResource]) -> Dictionary:
    var tag_totals := {}
    var tag_counts := {}
    var ingredient_names := []
    
    for ingredient in ingredients:
        ingredient_names.append(ingredient.card_name)
        for tag in ingredient.tags:
            var effect_val = ingredient.effect_data.get("value", 0)
            tag_totals[tag] = tag_totals.get(tag, 0) + effect_val
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
    
    # Multiply effects for tags with multiple ingredients
    for tag in tag_totals.keys():
        if tag_counts[tag] > 1:
            tag_totals[tag] *= tag_counts[tag]
    
    # Check for special recipes (exact order)
    for recipe in special_recipes.keys():
        if ingredient_names == recipe:
            return special_recipes[recipe]
    
    return tag_totals
func apply_card_effect(card: CardResource, target: Node):
    match card.effectID:
        1000: target.apply_burn(card.effect_efficency)
        1001: target.take_damage(card.effect_efficency)
        1002: target.heal(card.effect_efficency)
        1003: target.apply_poison(card.effect_efficency)
        1004: target.add_armor(card.effect_efficency)
        1005: target.apply_chaos(card.effect_efficency)
        1006: target.draw_cards(card.effect_efficency)
        1007: target.discard_cards(card.effect_efficency)
        _:
            print("Unknown effectID: %s" % card.effectID)