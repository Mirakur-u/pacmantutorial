extends Node

class_name PointsManager

@onready var ui: UI = $"../UI"

var points_for_ghost_eaten = 200
var points = 0

func pause_on_ghost_eaten():
	points += points_for_ghost_eaten
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	points_for_ghost_eaten *= 2
	ui.set_score(points)


func reset_points_for_ghosts():
	points_for_ghost_eaten = 200
