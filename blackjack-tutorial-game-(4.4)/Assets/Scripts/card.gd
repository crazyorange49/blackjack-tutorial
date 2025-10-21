extends Node3D

var value = 0
var card_scene: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _init(v, c):
	value = v
	card_scene = c
