extends CanvasLayer

class_name UI

@onready var center_container: CenterContainer = $MarginContainer/CenterContainer
@onready var life_count_label: Label = %LifeCountLabel
@onready var game_score_label: Label = %GameScoreLabel
@onready var game_label: Label = %GameLabel


func set_lives(lives):
	life_count_label.text = "%d Up" %lives
	if lives == 0:
		game_lost()

func set_score(score):
	game_score_label.text = "SCORE: %d" % score

func game_lost():
	game_label.text = "You Lost!"
	center_container.show()
	




func game_won():
	center_container.show()
