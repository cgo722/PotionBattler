extends Resource
class_name CharacterResource

@export var name: String
@export var starting_deck: Dictionary = {} # { CardResource: quantity }
@export var starting_health: int = 100
@export var target_health: int = 200 # Health goal to win the battle
@export var current_health: int = 100
@export var armor : int = 0
@export var ward: int = 0
@export var bless: int = 0
@export var ward_decay: int = 1 # How much ward decreases each trigger
@export var current_gold: int = 0
@export var starting_gold: int = 5