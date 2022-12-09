extends Node

var current_scene = 0
var max_lives = 3
var lives = max_lives
var hud

func lose_life():
	lives -= 1
	hud.load_hearts()
	if lives <= 0:
		get_tree().change_scene("res://Restart Screen.tscn") #GAME OVER SCREEEN
		lives = max_lives
