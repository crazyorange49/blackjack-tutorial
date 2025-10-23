extends Node
const card_class = preload("card.gd")

signal no_bet
signal game_started
signal deal_finished
signal game_ended

@onready var deck: Node = $Deck
@onready var dealer_hand: Node3D = $DealerHand
@onready var player_hand: Node3D = $PlayerHand
@onready var chip_stack: Node3D = $ChipStack


var Deck_array = []

var rng = RandomNumberGenerator.new()
const CARD_SPACING = 0.014
const CARD_PRIOTIRY_SPACING = 0.00075
const DELAY_TIME = 0.6

func _ready() -> void:
	init_deck()

func init_game():
	if chip_stack.total_bet <= 0:
		no_bet.emit()
		return
	game_started.emit()
	deal_card(player_hand)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(dealer_hand, true)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(player_hand)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(dealer_hand)
	deal_finished.emit()
	
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
	var num_of_cards = deck.get_child_count() - 1
	var rand_card_index = rng.randi_range(0, num_of_cards)
	var card = Deck_array[rand_card_index]
	Deck_array.remove_at(rand_card_index)
	var card_scene: Node3D = card.card_scene
	var card_position: Vector3 = Vector3(hand.last_card.position.x + CARD_SPACING if hand.last_card else 0.0,
										 hand.last_card.position.y + CARD_PRIOTIRY_SPACING if hand.last_card else 0.0,
										 0)
	var card_rotation: Vector3 = Vector3(90 if flip else -90, 0,  0)
	card_scene.reparent(hand, false)
	hand.move_child(card_scene, 0)
	card_scene.position = card_position
	card_scene.rotation_degrees = card_rotation
	hand.giveCard(card, flip)
	hand.last_card = card_scene
	if not hand.check_hand():
		return false
	return true

func _end_game_calculations() -> void:
	var dealer_value = dealer_hand.hand_value
	var player_value = player_hand.hand_value
	if dealer_value == 21 and player_value == 21:
		_player_won(true)
	elif player_value > dealer_value:
		_player_won()
	else:
		_reset_game()
		
func _player_won(is_pass:bool=false) -> void:
	var payout = 0
	if not is_pass:
		if player_hand.hand_value == 21:
			payout = ((chip_stack.total_bet / 2) * 3) + chip_stack.total_bet
		else:
			payout = chip_stack.total_bet + chip_stack.total_bet
	else:
		payout = chip_stack.total_bet
	Main.money += payout
	_reset_game()

func _reset_game() -> void:
	player_hand.clear_hand()
	dealer_hand.clear_hand()
	Deck_array.clear()
	chip_stack._on_clear_button_pressed(true)
	for child in deck.get_children():
		child.queue_free()
	init_deck()
	game_ended.emit()
