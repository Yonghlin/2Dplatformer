extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Restart_Game_Button_pressed():
	if Global.current_scene == 1:
		get_tree().change_scene("res://Level1.tscn")
		Global.current_scene = 1
	elif Global.current_scene == 2:
		get_tree().change_scene("res://Level2.tscn")
		Global.current_scene = 2
	elif Global.current_scene == 3:
		get_tree().change_scene("res://Level3.tscn")
		Global.current_scene = 3
	


func _on_Back_to_Main_pressed():
	get_tree().change_scene("res://Main Menu.tscn")
	Global.current_scene = 0
