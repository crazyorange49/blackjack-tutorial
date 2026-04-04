extends Node3D

@export var front_texture: Material

signal clicked

func _ready() -> void:
	$StaticBody3D/MeshInstance3D.material_override = front_texture

func  _mouse_enter() -> void:
	$AnimationPlayer.play("pick_up")

func  _mouse_exit() -> void:
	$AnimationPlayer.play_backwards("pick_up")



func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_released("click"):
		clicked.emit()
