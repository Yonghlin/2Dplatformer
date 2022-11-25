extends KinematicBody2D

var is_moving_right = true

var gravity = 10
var velocity = Vector2(0, 0)

var speed = 50

func _ready():
	$AnimatedSprite.play("walk")

func _process(delta):
	pass

func _physics_process(_delta):
	
	if is_moving_right:
		velocity.x = speed  
	else:
		velocity.x = -speed
	
	velocity.y += gravity
	
	if not $RayCast2D.is_colliding() and is_on_floor() or is_on_wall():
		#velocity.x *= -1
		is_moving_right = ! is_moving_right
		scale.x = -scale.x
		#$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		
	move_and_slide(velocity, Vector2.UP)
