extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Back_to_Main_pressed():
	get_tree().change_scene("res://Main Menu.tscn")
	Global.current_scene = 0
