extends Area2D

class_name Ghost

enum GhostState {
	SCATTER,
	CHASE,
}

signal direction_change(current_direction:String)

var current_scatter_index = 0
var direction = null
var current_state: GhostState

@export var speed = 120
@export var movement_targets: Resource
@export var tile_map: TileMap
@export var color: Color


@export var chasing_target: Node2D
@export var scatter_targets: Array[Node2D]
@export var at_home_targets: Array[Node2D]

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var body_sprite: Sprite2D = $BodySprite
@onready var eye_sprite: Sprite2D = $EyeSprite
@onready var scatter_timer: Timer = $ScatterTimer
@onready var pac_man: PacMan = $"../../PacMan"
@onready var update_chasing_target_position_timer: Timer = $UpdateChasingTargetPositionTimer

func _ready() -> void:
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.target_desired_distance = 4.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	call_deferred("setup")
	

func _process(delta: float):
	move_ghost(navigation_agent_2d.get_next_path_position(), delta)
	
	

func move_ghost(next_position: Vector2, delta: float):
	var current_ghost_position = global_position
	var new_velocity = (next_position - current_ghost_position).normalized() * speed * delta
	calculate_direction(new_velocity)
	position += new_velocity
	if current_state == GhostState.SCATTER:
		scatter()

func calculate_direction(new_velocity: Vector2):
	
	var current_direction
	

	if abs(new_velocity.x) > abs(new_velocity.y):
		if new_velocity.x > 0:
			current_direction = "right"
		elif new_velocity.x < 0:
			current_direction = "left"
	elif abs(new_velocity.y) > abs(new_velocity.x):
		if new_velocity.y > 0:
			current_direction = "down"
		elif new_velocity.y < 0:
			current_direction = "up"

	if current_direction != direction:
		direction = current_direction
		direction_change.emit(direction)


func setup():
	navigation_agent_2d.set_navigation_map(tile_map.get_navigation_map(0))
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), tile_map.get_navigation_map(0))
	scatter_timer.start()
	scatter()


func scatter():
	navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position
	current_state = GhostState.SCATTER
	if current_state != GhostState.SCATTER:
		scatter_timer.start()



func on_position_reached():
	if current_state == GhostState.SCATTER:
		scatter_position_reached()
	elif current_state == GhostState.CHASE:
		chase_position_reached()

func scatter_position_reached():
	if current_scatter_index < 3:
		current_scatter_index += 1
	else:
		current_scatter_index = 0
		

	navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position


func _on_scatter_timer_timeout() -> void:
	start_chasing_pacman()
	

func start_chasing_pacman():
	#if chasing_target == null:
		#chasing_target = PacMan
	current_state = GhostState.CHASE
	update_chasing_target_position_timer.start()
	navigation_agent_2d.target_position = chasing_target.position


func _on_update_chasing_target_position_timer_timeout() -> void:
	navigation_agent_2d.target_position = chasing_target.position

func chase_position_reached():
	print("KILL PACMAN")
