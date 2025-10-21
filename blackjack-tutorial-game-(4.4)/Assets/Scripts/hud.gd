extends Control

@onready var money_lable: Label = $Lables/MoneyLable
@onready var bet_lable: Label = $Lables/BetLable
@onready var chip_stack: Node3D = $"../GameManager/ChipStack"
@onready var bet_buttons: Control = $BetButtons
@onready var subtraction_buttons: Control = $SubtractionButtons
@onready var player_actions: Label = $PlayerActions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_lables()

func _update_lables() -> void: 
	money_lable.text = "money : $" + str(Main.money)
	bet_lable.text = "bet : $" + str(chip_stack.total_bet)
	
func _update_ui(state: bool) -> void:
	bet_buttons.visible = state
	subtraction_buttons.visible = state
	player_actions.visible =  not state
	
