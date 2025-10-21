extends Node
const card_class = preload("card.gd")

signal no_bet
signal game_started

@onready var deck: Node = $Deck
@onready var dealer_hand: Node3D = $DealerHand
@onready var player_hand: Node3D = $PlayerHand
@onready var chip_stack: Node3D = $ChipStack


var Deck_array = []



var last_card: Node3D = null
var rng = RandomNumberGenerator.new()
const CARD_SPACING = 0.01
const CARD_PRIOTIRY_SPACING = 0.00038

func _ready() -> void:
	init_deck()

func init_game():
	if chip_stack.total_bet <= 0:
		no_bet.emit()
		return
	
	deal_card(player_hand)
	await get_tree().create_timer(1).timeout
	deal_card(dealer_hand, true)
	await get_tree().create_timer(1).timeout
	deal_card(player_hand)
	await get_tree().create_timer(1).timeout
	deal_card(dealer_hand)
	game_started.emit()
func init_deck():
	for suit in range(4):
		var res_suit_path: String = "res://Assets/Scenes/Cards/" + str(suit) + "/"
		var cards = DirAccess.get_files_at(res_suit_path)
		for card_file_name in cards:
			var card_scene: Node3D = load(res_suit_path + "/" + card_file_name).instantiate()
			var values = card_file_name.split(".")
			var card_object: = card_class.new(int(values[0]), card_scene)
			Deck_array.append(card_object)
			deck.add_child(card_scene)
			card_object.card_scene.rotation_degrees.x = -90


func deal_card(hand: Node3D, flip: bool = false) -> bool:
	if not hand.check_hand():
		return false
		
	var num_of_cards = deck.get_child_count() - 1
	var rand_card_index = rng.randi_range(0, num_of_cards)
	var card = Deck_array[rand_card_index]
	Deck_array.remove_at(rand_card_index)
	var card_scene: Node3D = card.card_scene
	var card_position: Vector3 = Vector3(last_card.position.x + CARD_SPACING if last_card else 0.0,
										 last_card.position.y + CARD_PRIOTIRY_SPACING if last_card else 0.0,
										 0)
	var card_rotation: Vector3 = Vector3(90 if flip else -90, 0,  0)
	card_scene.reparent(hand, false)
	hand.move_child(card_scene, 0)
	card_scene.position = card_position
	card_scene.rotation_degrees = card_rotation
	hand.giveCard(card)
	last_card = card_scene
	return true
