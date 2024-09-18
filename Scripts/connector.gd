extends Node2D

class_name Connector

@onready var right_area: Area2D = $RightColorRect/Area2D
@onready var left_area: Area2D = $LeftColorRect/Area2D

var allow_left_transition = true
var allow_right_transition = true

func _on_right_area_body_entered(body: Node2D) -> void:
	if allow_right_transition:
		body.position.x = left_area.global_position.x
		allow_left_transition = false



func _on_right_area_body_exited(body: Node2D) -> void:
	allow_left_transition = true



func _on_left_area_body_entered(body: Node2D) -> void:
	if allow_left_transition:
		body.position.x = right_area.global_position.x
		allow_right_transition = false


func _on_left_area_body_exited(body: Node2D) -> void:
	allow_right_transition = true
