extends Node2D

@export var character_resource: Resource # Assign your CharacterResource in the editor

var current_health: int
var max_health: int

func _ready():
    if character_resource:
        current_health = character_resource.current_health
        max_health = character_resource.max_health

func take_damage(amount: int):
    current_health = max(current_health - amount, 0)
    print("Took", amount, "damage. Health:", current_health)

func heal(amount: int):
    current_health = min(current_health + amount, max_health)
    print("Healed", amount, "Health:", current_health)

func apply_burn(amount: int):
    take_damage(amount)
    print("Burned for", amount)

func apply_poison(amount: int):
    # Implement poison logic
    pass

func add_armor(amount: int):
    # Implement armor logic
    pass

# Add more as needed