extends Resource
class_name CharacterResource

@export var character_name: String
@export var starting_deck: Dictionary = {} # { "Firebloom": 3, "Frogsweat": 2 }
@export var starting_health: int = 100
@export var current_health: int = 100