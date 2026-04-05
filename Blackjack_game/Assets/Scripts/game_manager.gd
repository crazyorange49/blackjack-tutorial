extends Node
const card_class = preload("card.gd")

# Signals for game state events
signal no_bet
signal card_delt
signal game_started
signal table_set
signal deal_finished
signal game_ended

@onready var deck: Node = $Deck
@onready var dealer_hand: Node3D = $DealerHand
@onready var player_hand: Node3D = $PlayerHand
@onready var chip_stack: Node3D = $ChipStack



var Deck_array = []
var numCardsFreed = 0

var rng = RandomNumberGenerator.new()
const CARD_SPACING = 0.014
const CARD_PRIOTIRY_SPACING = 0.00075
const DELAY_TIME = 0.6

func _set_table() -> void:
	init_deck()
	table_set.emit()

func _ready() -> void:
	init_deck()

func init_game():
	# Abort if no bet has been placed
	if chip_stack.total_bet <= 0:
		no_bet.emit()
		return
	game_started.emit()
	# Deal two cards each, dealer's first card is face-down
	deal_card(player_hand)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(dealer_hand, true)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(player_hand)
	await get_tree().create_timer(DELAY_TIME).timeout
	deal_card(dealer_hand)
	deal_finished.emit()
	
func init_deck():
	# Loop through all 4 suits and load every card scene from its folder
	for suit in range(4):
		var res_suit_path: String = "res://Assets/Scenes/Cards/" + str(suit) + "/"
		var cards = DirAccess.get_files_at(res_suit_path)
		for card_file_name in cards:
			var card_scene: Node3D = load(res_suit_path + "/" + card_file_name).instantiate()
			# File name holds the card value (e.g. "4.0.0.tscn")
			var values = card_file_name.split(".")
			var card_object: = card_class.new(int(values[0]), card_scene)
			Deck_array.append(card_object)
			deck.add_child(card_scene)
			# Lay card flat on the table facing up
			card_object.card_scene.rotation_degrees.x = -90


func deal_card(hand: Node3D, flip: bool = false) -> bool:
	# Pick a random card from the remaining deck
	var num_of_cards = deck.get_child_count() - 1
	var rand_card_index = rng.randi_range(0, num_of_cards)
	var card = Deck_array[rand_card_index]
	Deck_array.remove_at(rand_card_index)
	var card_scene: Node3D = card.card_scene
	# Stack the card slightly offset from the previous card in the hand
	var card_position: Vector3 = Vector3(hand.last_card.position.x + CARD_SPACING if hand.last_card else 0.0,
										 hand.last_card.position.y + CARD_PRIOTIRY_SPACING if hand.last_card else 0.0,
										 0)
	# Flip face-down if flagged, otherwise face-up
	var card_rotation: Vector3 = Vector3(90 if flip else -90, 0,  0)
	card_scene.reparent(hand, false)
	hand.move_child(card_scene, 0)
	card_scene.position = card_position
	card_scene.rotation_degrees = card_rotation
	card_delt.emit()
	hand.giveCard(card, flip)
	hand.last_card = card_scene
	# Return false if the hand is bust or otherwise invalid
	if not hand.check_hand():
		return false
	return true

func _end_game_calculations() -> void:
	var dealer_value = dealer_hand.hand_value
	var player_value = player_hand.hand_value
	# Tie goes to the player, otherwise highest hand wins
	if dealer_value == player_value:
		_player_won(true)
	elif player_value > dealer_value:
		_player_won()
	else:
		_reset_game()
		
func _player_won(is_pass:bool=false) -> void:
	var payout = 0
	if not is_pass:
		# Blackjack pays 1.5x, any other win pays 1x
		if player_hand.hand_value == 21:
			payout = (chip_stack.total_bet * 1.5) + chip_stack.total_bet
		else:
			# Tie returns the original bet only
			payout = chip_stack.total_bet + chip_stack.total_bet
	else:
		payout = chip_stack.total_bet
	Main.money += payout
	_reset_game()

func _reset_game() -> void:
	player_hand.clear_hand()
	dealer_hand.clear_hand()
	# Free all card scenes from the deck node and track count for debugging
	for child in deck.get_children():
		child.free()
		numCardsFreed += 1
	Deck_array.clear()
	chip_stack._on_clear_button_pressed(true)
	init_deck()
	game_ended.emit()
	print("Number of Cards freed " + str(numCardsFreed))
	numCardsFreed = 0
