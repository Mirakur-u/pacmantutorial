extends Area2D

class_name Pellet
signal pellet_eaten()

@export var should_allow_eating_ghosts:bool = false



func _on_body_entered(body: Node2D) -> void:
	if body is PacMan:
		pellet_eaten.emit()
		queue_free()
	# TODO: add interaction with player class to enable eating ghosts
	if should_allow_eating_ghosts:
		pass
