extends Resource
class_name CharacterResource

@export var character_name: String
@export var starting_deck: Dictionary = {} # { CardResource: quantity }
@export var starting_health: int = 100
@export var current_health: int = 100
@export var aromor : int = 0
@export var burn: int = 0
@export var poison: int = 0
@export var burn_strength: int = 1 # How much burn decreases each trigger