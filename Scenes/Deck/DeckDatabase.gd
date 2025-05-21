extends Node
#class_name CardDatabase

var cards: Dictionary = {}

func _ready():
    # Load all card resources from a folder
    var dir = DirAccess.open("res://Scenes/Deck/Cards/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var card = load("res://Scenes/Deck/Cards/" + file_name)
                if card is CardResource:
                    cards[card.card_name] = card
            file_name = dir.get_next()
        dir.list_dir_end()

func get_card_by_name(card_name: String) -> CardResource:
    return cards.get(card_name, null)

func get_all_cards() -> Array:
    return cards.values()