extends KinematicBody2D

const ATTACK_CD = .25

var gravity = 10
var speed = 50
var attacking = false
var velocity = Vector2(0, 0)
var attack_timer = Timer.new()
var is_moving_right = true
var facing_right = true

func start_attack():
	attacking = true
	$AttackArea.visible = true
	$AnimatedSprite.play("attack")
	attack_timer.start()

func end_attack():
	attacking = false
	$AttackArea.visible = false

func _ready():
	$AnimatedSprite.play("walk")
	
	attack_timer.connect("timeout", self, "end_attack")
	attack_timer.set_one_shot(true)
	attack_timer.set_wait_time(ATTACK_CD)
	self.add_child(attack_timer)

func _process(delta):
	move_character()
	detect_turn_around()

func move_character():
	if is_moving_right:
		velocity.x = speed  
	else:
		velocity.x = -speed
	
	velocity.y += gravity
	
	move_and_slide(velocity, Vector2.UP)

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor() or is_on_wall():
		is_moving_right = ! is_moving_right
		facing_right = ! facing_right
		scale.x = -scale.x

func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player"):
		start_attack()

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		Global.lose_life()
		#get_tree().reload_current_scene()
