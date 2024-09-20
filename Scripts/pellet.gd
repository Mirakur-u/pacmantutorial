extends Area2D

class_name Pellet

signal pellet_eaten(should_allow_eating_ghosts: bool)

@export var should_allow_eating_ghosts:bool = false



func _on_body_entered(body: Node2D) -> void:
	if body is PacMan:
		pellet_eaten.emit(should_allow_eating_ghosts)
		queue_free()
