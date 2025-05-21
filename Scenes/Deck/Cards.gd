extends Resource
class_name CardResource

@export var card_name: String
@export var description: String
@export var card_type: String # e.g. "Ingredient", "Potion", etc.
@export var tags: Array[String] = []
@export var sprite: Texture2D
@export var effect_data: Dictionary = {} # For custom effect info
@export var keywords: Array[String] = [] # For custom keywords