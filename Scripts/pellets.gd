extends Node

class_name PelletsSpawner

var total_pellets_count
var pellets_eaten = 0
@onready var ui: UI = $"../UI"
@onready var ghosts: Node = $"../Ghosts"
@onready var red_ghost: Ghost = $"../Ghosts/RedGhost"
@onready var yellow_ghost: Ghost = $"../Ghosts/YellowGhost"
@onready var pink_ghost: Ghost = $"../Ghosts/PinkGhost"
@onready var blue_ghost: Ghost = $"../Ghosts/BlueGhost"
@onready var run_away_timer: Timer = $RunAwayTimer
@onready var points_manager: PointsManager = $"../PointsManager"
@onready var chomp_sound_player: AudioStreamPlayer2D = $"../SoundPlayers/ChompSoundPlayer"
@onready var power_pellet_sound: AudioStreamPlayer2D = $"../SoundPlayers/PowerPelletSound"


@export var ghost_array: Array[Ghost]


func _ready():
	var pellets = self.get_children() as Array[Pellet]
	total_pellets_count = pellets.size()
	for pellet in pellets:
		pellet.pellet_eaten.connect(on_pellet_eaten)
		
	

func on_pellet_eaten(should_allow_eating_ghosts: bool):
	pellets_eaten += 1
	
	if !chomp_sound_player.playing:
		chomp_sound_player.play()
	
	if should_allow_eating_ghosts:
		power_pellet_sound.play()
		get_tree().create_timer(8).timeout.connect(reset_points_for_ghosts)
		for Ghost in ghost_array:
			if Ghost.current_state != Ghost.GhostState.STARTING_AT_HOME:
				Ghost.run_away_from_pacman()
	
	if pellets_eaten == total_pellets_count:
		ui.game_won()

func reset_points_for_ghosts():
	points_manager.reset_points_for_ghosts()
	power_pellet_sound.stop()
