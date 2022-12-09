extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Start_Game_Button_pressed():
	get_tree().change_scene("res://Level1.tscn")
	Global.current_scene = 1


func _on_Quit_Game_Button_pressed():
	get_tree().quit()
	Global.current_scene = 0

#Temporary until John does the save system
func _on_Load_Button_pressed():
	get_tree().change_scene("res://Load scene.tscn")
	Global.current_scene = 5
	

func _on_Help_Button_pressed():
	get_tree().change_scene("res://Help Screen.tscn")
	Global.current_scene = 4
