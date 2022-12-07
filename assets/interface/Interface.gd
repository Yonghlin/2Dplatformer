extends Control

func _ready():
	load_hearts()
	Global.hud = self

func load_hearts():
	$CanvasLayer/HeartsFull.rect_size.x = Global.lives * 53
	$CanvasLayer/HeartsEmpty.rect_size.x = (Global.max_lives - Global.lives) * 53
	$CanvasLayer/HeartsEmpty.rect_position.x = $CanvasLayer/HeartsFull.rect_position.x + $CanvasLayer/HeartsFull.rect_size.x * $CanvasLayer/HeartsFull.rect_scale.x
