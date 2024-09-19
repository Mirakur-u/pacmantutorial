extends Sprite2D


@onready var ghost: Ghost = $".."
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


func _ready() -> void:
	self.modulate = (get_parent() as Ghost).color
	animation_player.play("default")
