extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Chest_body_entered(body):
	if body.is_in_group("Player"):
		$ChestSound.play()
		$Sprite.play("open")
		yield($ChestSound, "finished")
		
		if get_tree().current_scene.filename == "res://Level1.tscn":
			get_tree().change_scene("res://Level2.tscn")
			Global.current_scene = 2
		
		if get_tree().current_scene.filename == "res://Level2.tscn":
			get_tree().change_scene("res://Level3.tscn")
			Global.current_scene = 3
		
		if get_tree().current_scene.filename == "res://Level3.tscn":
			get_tree().change_scene("res://End Scene.tscn")
			Global.current_scene = 6
			
