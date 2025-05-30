extends Resource
class_name CardResource

@export var card_name: String
@export var description: String
@export var rarity: String # e.g. "Common", "Rare", "Epic", "Legendary"
@export var tags: Array[String] = []
@export var sprite: Texture2D
@export var card_text: String # For visual display
@export var effects: Array[Resource] = []
@export var price: int = 0

# Define each effect in a separate CardEffect resource
# CardEffect.gd should have: effect_type (String), value (int), optional: target (String)