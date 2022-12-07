extends KinematicBody2D

var speed = 6000
var velocity = Vector2()

func _physics_process(delta: float) -> void:
	var to_player = ($"../Player".position-position).normalized()

	velocity = to_player * speed
	
	#if velocity < 0:
	#	$Bird.set_horizontal_flip(true)
	#elif velocity > 0:
	#	$Bird.set_horizontal_flip(false)

	move_and_slide(velocity*delta)
