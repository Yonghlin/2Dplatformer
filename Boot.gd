extends Area2D

func _on_Boot_body_entered(body):
	queue_free()
	
	if body.is_in_group("Player"):
		body.boot_entered()
