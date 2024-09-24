extends Area2D

class_name Ghost

enum GhostState {
	SCATTER,
	CHASE,
	RUN_AWAY,
	EATEN,
	STARTING_AT_HOME
}

signal direction_change(current_direction:String)

var current_scatter_index = 0
var current_at_home_index = 0
var direction = null
var current_state: GhostState
var is_blinking = false

@export var speed = 120
@export var eaten_speed = 240
@export var movement_targets: Resource
@export var tile_map: MazeTileMap
@export var color: Color


@export var chasing_target: Node2D
@export var scatter_targets: Array[Node2D]
@export var at_home_targets: Array[Node2D]
@export var starting_position: Node2D
@export var points_manage: PointsManager
@export var is_starting_at_home: bool
@export var starting_texture : Texture2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var body_sprite: BodySprite = $BodySprite
@onready var eye_sprite: EyeSprite = $EyeSprite
@onready var scatter_timer: Timer = $ScatterTimer
@onready var pac_man: PacMan = $"../../PacMan"
@onready var update_chasing_target_position_timer: Timer = $UpdateChasingTargetPositionTimer
@onready var run_away_timer: Timer = $RunAwayTimer
@onready var points_label: Label = $PointsLabel
@onready var points_manager: PointsManager = $"../../PointsManager"
@onready var at_home_timer: Timer = $AtHomeTimer
@onready var eat_ghost_sound: AudioStreamPlayer2D = $"../../SoundPlayers/EatGhostSound"

func _ready() -> void:
	pac_man.player_died.connect(setup)
	navigation_agent_2d.path_desired_distance = 4.0
	navigation_agent_2d.target_desired_distance = 4.0
	navigation_agent_2d.target_reached.connect(on_position_reached)
	body_sprite.texture = starting_texture
	call_deferred("setup")
	

func _process(delta: float):
	if !run_away_timer.is_stopped() && run_away_timer.time_left < run_away_timer.wait_time /2 && !is_blinking:
		start_blinking()
	move_ghost(navigation_agent_2d.get_next_path_position(), delta)
	
	

func move_ghost(next_position: Vector2, delta: float):
	var current_ghost_position = global_position
	var current_speed = eaten_speed if current_state == GhostState.EATEN else speed
	var new_velocity = (next_position - current_ghost_position).normalized() * current_speed * delta
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
	position = starting_position.position
	body_sprite.move()
	body_sprite.visible
	navigation_agent_2d.set_navigation_map(tile_map.get_navigation_map(0))
	NavigationServer2D.agent_set_map(navigation_agent_2d.get_rid(), tile_map.get_navigation_map(0))
	if is_starting_at_home:
		start_at_home()
	else:
		scatter_timer.start()
		scatter()

func start_at_home():
	current_state = GhostState.STARTING_AT_HOME
	at_home_timer.start()
	navigation_agent_2d.target_position = at_home_targets[current_at_home_index].position
	move_to_next_home_position()

func scatter():
	navigation_agent_2d.target_position = scatter_targets[current_scatter_index].position
	if current_state != GhostState.SCATTER:
		scatter_timer.start()
		current_state = GhostState.SCATTER
	



func on_position_reached():
	if current_state == GhostState.SCATTER:
		scatter_position_reached()
	elif current_state == GhostState.CHASE:
		chase_position_reached()
	elif current_state == GhostState.RUN_AWAY:
		run_away_from_pacman()
	elif current_state == GhostState.EATEN:
		start_chasing_pacman_after_being_eaten()
	elif current_state == GhostState.STARTING_AT_HOME:
		move_to_next_home_position()
	
	

func move_to_next_home_position():
	if current_at_home_index == 0:
		current_at_home_index = 1
		navigation_agent_2d.target_position = at_home_targets[1].position
	else: current_at_home_index = 0
	navigation_agent_2d.target_position = at_home_targets[0].position


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

func start_chasing_pacman_after_being_eaten():
	start_chasing_pacman()
	body_sprite.show()
	body_sprite.move()

func chase_position_reached():
	print("KILL PACMAN")


func run_away_from_pacman():
	run_away_timer.start()
	body_sprite.run_away()
	eye_sprite.hide_eyes()
	current_state = GhostState.RUN_AWAY
	
	update_chasing_target_position_timer.stop()
	scatter_timer.stop()
	
	var empty_cell_position = tile_map.get_random_empty_cell_position()
	navigation_agent_2d.target_position = empty_cell_position

func start_blinking():
	body_sprite.start_blinking

func _on_run_away_timer_timeout() -> void:
	is_blinking = false
	eye_sprite.show_eyes()
	body_sprite.move()
	start_chasing_pacman()


func _on_body_entered(body: Node2D) -> void:
	var player = body as PacMan
	if current_state == GhostState.RUN_AWAY:
		get_eaten()
	elif current_state == GhostState.SCATTER || current_state == GhostState.CHASE:
		update_chasing_target_position_timer.stop()
		player.die()
		scatter_timer.wait_time = 600
		scatter()

func get_eaten():
	eat_ghost_sound.play()
	body_sprite.hide()
	eye_sprite.show_eyes()
	points_label.show()
	points_label.text = "%d" % points_manage.points_for_ghost_eaten
	await points_manage.pause_on_ghost_eaten()
	points_label.hide()
	run_away_timer.stop()
	current_state = GhostState.EATEN
	navigation_agent_2d.target_position = at_home_targets[0].position


func _on_at_home_timer_timeout() -> void:
	scatter()
