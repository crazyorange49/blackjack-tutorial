extends Node3D

const MAX_HAND_VALUE = 21
const DELAY_TIME = 0.6
@onready var dealer_hand_value: Label3D = $"../DealerHandValue"

signal game_won
signal dealer_stand
signal dealer_hit(hand)

var cards_in_hand = []
var flipped_card = null
var hand_value = 0
var aces_as_eleven = 0
var last_card = null

func clear_hand():
	cards_in_hand.clear()
	last_card = null
	aces_as_eleven = 0
	hand_value = 0
	flipped_card = null
	for child in self.get_children():
		child.free()
	update_hand_value_display()


func getValue() -> int:
	while(hand_value > MAX_HAND_VALUE and aces_as_eleven>0):
		hand_value -= 10
		aces_as_eleven -= 1
	return hand_value
	
func check_hand() -> bool:
	if getValue() > MAX_HAND_VALUE:
		return false
	return true
	

func giveCard(card, flipped: bool):
	cards_in_hand.append(card)
	var card_value = card.value
	hand_value += card_value
	if flipped:
		flipped_card = card
	if card_value == 11:
		aces_as_eleven += 1
	update_hand_value_display()


func update_hand_value_display():
	dealer_hand_value.text = str(clamp(getValue(), 0, 21) - (flipped_card.value if flipped_card != null else 0))


func _dealer_turn():
	flipped_card.card_scene.rotation_degrees = Vector3(-90,0,0)
	flipped_card = null
	update_hand_value_display()
	while getValue() <= 16:
		await get_tree().create_timer(DELAY_TIME).timeout
		dealer_hit.emit(self)
		if not check_hand():
			await get_tree().create_timer(DELAY_TIME).timeout
			game_won.emit()
			break
	if getValue() >= 17:
		await get_tree().create_timer(DELAY_TIME).timeout
		dealer_stand.emit()
