extends Node3D

const MAX_HAND_VALUE = 21

@onready var game_manager: Node = $".."
signal game_lost

var cards_in_hand = []
var hand_value = 0
var aces_as_eleven = 0

func getValue() -> int:
	while(hand_value > MAX_HAND_VALUE and aces_as_eleven>0):
		hand_value -= 10
		aces_as_eleven -= 1
	return hand_value

func giveCard(card):
	cards_in_hand.append(card)
	var card_value = card.value
	hand_value += card_value
	if card_value == 11:
		aces_as_eleven += 1

func check_hand() -> bool:
	if getValue() > MAX_HAND_VALUE:
		return false
	return true


func _hit():
	var deal_card_status: bool = game_manager.deal_card(self)
	if not deal_card_status:
		game_lost.emit()
