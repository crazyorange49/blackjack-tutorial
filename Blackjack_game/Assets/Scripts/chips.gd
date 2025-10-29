extends Node3D

const CHIP_SPACING = 0.002

signal bet_changed
signal chip_added

var total_bet = 0
var chips_in_stack: Array = []
var rng = RandomNumberGenerator.new()

func get_recent_chip_of_value(chip_value) -> Node3D:
	var chip: Node3D = null
	if chips_in_stack:		
		for i in range(chips_in_stack.size()-1, -1, -1):
			if chips_in_stack[i].value == chip_value:
				chip = chips_in_stack[i]
				break
	return chip

func _on_bet_pressed(bet_amount: int) -> void:
	if Main.money < bet_amount:
		return
	self.total_bet += bet_amount
	Main.money -= bet_amount
	var last_chip_of_value: Node3D = get_recent_chip_of_value(bet_amount)
	var chip_position = get_node("Chip" + str(bet_amount) + "Spot").position
	chip_position = Vector3(chip_position.x, 
							last_chip_of_value.position.y + CHIP_SPACING if last_chip_of_value else chip_position.y,
							chip_position.z)
	var res_chip_path = "res://Assets/Scenes/Models/chip_" + str(bet_amount) + ".tscn"
	var chip: Node3D = load(res_chip_path).instantiate()
	chip.value = bet_amount
	self.add_child(chip)
	self.move_child(chip, 0)
	chips_in_stack.append(chip)
	chip.position = chip_position
	chip.rotation_degrees.y = rng.randi_range(0, 360)
	chip_added.emit(true if last_chip_of_value == null else false)
	bet_changed.emit()
	

func _on_subtract_pressed(bet_amount: int) -> void:
	var recent_relivant_chip: Node3D = get_recent_chip_of_value(bet_amount)
	if total_bet >= bet_amount and recent_relivant_chip:
		self.total_bet -= bet_amount
		Main.money += bet_amount
		chips_in_stack.erase(recent_relivant_chip)
		recent_relivant_chip.queue_free()
	bet_changed.emit()


func _on_clear_button_pressed(is_loss: bool = false) -> void:
	if not chips_in_stack.is_empty():
		for chip: Node3D in chips_in_stack:
			chip.queue_free()
		if not is_loss:
			Main.money += total_bet
		total_bet = 0
		chips_in_stack.clear()
	bet_changed.emit()
