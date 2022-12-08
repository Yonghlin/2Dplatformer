extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	 globals.currentStage = 0

func _on_Start_Game_Button_pressed():
	get_tree().change_scene("res://Level1.tscn")


func _on_Quit_Game_Button_pressed():
	get_tree().quit()


func _on_Load_Button_pressed():
	pass
	

func _on_Help_Button_pressed():
	get_tree().change_scene("res://Help Screen.tscn")
