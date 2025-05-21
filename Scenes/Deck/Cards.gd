extends Resource
class_name CardResource

@export var card_name: String
@export var description: String
@export var rarity: String # e.g. "Common", "Rare", "Epic", "Legendary"
@export var tags: Array[String] = []
@export var sprite: Texture2D
@export var effectID: int # For effect identification
@export var effect_efficency: int # For effect strength
@export var card_text: String # For visual display

#effects Burn = 1000, Damage = 1001, Heal = 1002, Poison = 1003, Armor = 1004, Chaos = 1005, Draw = 1006, Discard = 1007