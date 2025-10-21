extends Node3D

const MAX_HAND_VALUE = 21
const DELAY_TIME = 0.6

@onready var game_manager: Node = $".."
@onready var player_hand_value: Label3D = $"../PlayerHandValue"

signal game_lost

var cards_in_hand = []
var hand_value = 0
var aces_as_eleven = 0
var last_card = null

func clear_hand():
	last_card = null
	aces_as_eleven = 0
	hand_value = 0
	for child in self.get_children():
		child.free()
	update_hand_value_display()

func getValue() -> int:
	while(hand_value > MAX_HAND_VALUE and aces_as_eleven>0):
		hand_value -= 10
		aces_as_eleven -= 1
	return hand_value

func giveCard(card, flipped: bool):
	cards_in_hand.append(card)
	var card_value = card.value
	hand_value += card_value
	if card_value == 11:
		aces_as_eleven += 1
	update_hand_value_display()

func check_hand() -> bool:
	if getValue() == MAX_HAND_VALUE:
		game_lost.emit()
	if getValue() > MAX_HAND_VALUE:
		return false
	return true

func update_hand_value_display():
	player_hand_value.text = str(clamp(getValue(), 0, 99))

func _hit():
	var deal_card_status: bool = game_manager.deal_card(self)
	await get_tree().create_timer(DELAY_TIME).timeout
	if not deal_card_status:
		game_lost.emit()
