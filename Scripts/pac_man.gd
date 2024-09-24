extends CharacterBody2D

class_name PacMan

signal player_died(lives: int)

var next_movement_direction = Vector2.ZERO
var movement_direction = Vector2.ZERO
var shape_query = PhysicsShapeQueryParameters2D.new()
var lives : int = 3

@export var speed = 300
@export var start_position: Node2D

@onready var direction_pointer: Sprite2D = $DirectionPointer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_start: Marker2D = $"../MovementTargets/PlayerStart"
@onready var pacman_death_sound: AudioStreamPlayer2D = $"../SoundPlayers/PacmanDeathSound"
@onready var power_pellet_sound: AudioStreamPlayer2D = $"../SoundPlayers/PowerPelletSound"
@onready var ui: UI = $"../UI"

func _ready():
	shape_query.shape = collision_shape_2d.shape
#	shape_query.collide_with_areas = false
#	shape_query.collide_with_bodies = true
	shape_query.collision_mask = 2
	reset_player()


func _physics_process(delta: float) -> void:
	get_input()
	if movement_direction == Vector2.ZERO:
		movement_direction = next_movement_direction
	if can_move_in_direction(next_movement_direction, delta):
		movement_direction = next_movement_direction
	
	velocity = movement_direction * speed
	move_and_slide()

func get_input():
	
	if Input.is_action_pressed("left"):
		next_movement_direction = Vector2.LEFT
		rotation_degrees = 0
	elif Input.is_action_pressed("right"):
		next_movement_direction = Vector2.RIGHT
		rotation_degrees = 180
	elif Input.is_action_just_pressed("down"):
		next_movement_direction = Vector2.DOWN
		rotation_degrees = 270
	elif Input.is_action_pressed("up"):
		next_movement_direction = Vector2.UP
		rotation_degrees = 90

func can_move_in_direction(dir: Vector2, delta: float) -> bool:
	shape_query.transform = global_transform.translated(dir*speed*delta*2)
	var result = get_world_2d().direct_space_state.intersect_shape(shape_query)
	return result.size() == 0

func die():

	power_pellet_sound.stop()
	set_collision_layer_value(1, false)
	animation_player.play("death")
	set_physics_process(false)
	pacman_death_sound.play()

func reset_player():
	animation_player.play("default")
	position = start_position.position
	set_collision_layer_value(1, true)
	set_physics_process(true)
	next_movement_direction = Vector2.ZERO
	movement_direction = Vector2.ZERO


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	lives -= 1
	#if lives == 0:
	#	game_over()
	if anim_name == "death":
		ui.set_lives(lives)
		player_died.emit(lives)
		if lives >0:
			reset_player()
