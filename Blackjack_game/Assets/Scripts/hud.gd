extends Control

@onready var money_lable: Label = $Lables/MoneyLable
@onready var bet_lable: Label = $Lables/BetLable
@onready var chip_stack: Node3D = $"../GameManager/ChipStack"
@onready var bet_buttons: Control = $BetControls/BetButtons
@onready var subtraction_buttons: Control = $BetControls/SubtractionButtons
@onready var player_actions: Control = $PlayerActions
@onready var bet_controls: Control = $BetControls


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_lables()

func _update_lables() -> void: 
	money_lable.text = "money : $" + str(Main.money)
	bet_lable.text = "bet : $" + str(chip_stack.total_bet)
	
func _update_bet_controls(state: bool) -> void:
	bet_controls.visible = state

func _update_player_actions(state: bool) -> void:
	player_actions.visible = state

func _game_end() -> void:
	bet_controls.visible = true
	player_actions.visible = false

func _update_ui(state: bool) -> void:
	bet_controls.visible = state
	player_actions.visible = state
