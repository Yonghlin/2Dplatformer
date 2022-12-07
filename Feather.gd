extends Area2D


func _on_Feather_body_entered(body):
	queue_free()
	if body.is_in_group("Player"):
		body.feather_entered()

