extends Sprite2D

class_name BodySprite


@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var eye_sprite: Sprite2D = $"../EyeSprite"


func _ready() -> void:
	move()


func move():
	self.modulate = (get_parent() as Ghost).color
	animation_player.play("default")



func run_away():
	self.modulate = Color.WHITE
	animation_player.play("running_away")

func start_blinking():
	animation_player.play("blinking")
