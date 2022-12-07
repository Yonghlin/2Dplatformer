# Author: Michael Frank

extends KinematicBody2D

# Child node imports.
# you should never call the get_node() function inside the _process() function,
# as it will actively search the path of each node for every single frame.
# this needlessly wastes CPU, so it's better to store the results in variables
# if you will be referencing them constantly.
onready var _sprite				= get_node("./AnimatedSprite")
onready var _dash_particle		= get_node("./Particle/DashParticle")
onready var _jump_particle		= get_node("./Particle/JumpParticle")
onready var _splash_particle	= get_node("./Particle/SplashParticle")
onready var _dash_sound			= get_node("./Sound/DashSound")
onready var _jump_sound			= get_node("./Sound/JumpSound")
onready var _splash_sound		= get_node("./Sound/SplashSound")
onready var _flap_sound			= get_node("./Sound/FlapSound")

# Item node imports
onready var __feather			= get_node("../World/Items/Feather")
onready var __boot				= get_node("../World/Items/Boot")
onready var __coin				= get_node("../World/Items/Coin")

# Constants that are essential to physics
const ORIGIN_X					= 350		# player's starting x-coord
const ORIGIN_Y					= 350		# player's starting y-coord

const GRAVITY					= 70		# added to player's y-vel every frame
const MOVESPEED_DEFAULT			= 400		# player's default movespeed
const SPEEDBOOST_MULT			= 1.5		# `movespeed` *= this when player has speedboost powerup

const JUMPIMPULSE				= -1100		# added to player's y-vel on successful jump
const INAIR_SPEED				= 0.5		# x-vel is multiplied by this when in midair
const WATER_SPEED				= 0.75		# y-vel is multiplied by this when "underwater"

const DASHIMPULSE 				= 1490 		# added to player's x-vel on successful dash
const DASH_PARTICLE_VELOCITY	= -8 		# reflects which direction player is facing
const DASH_CD					= 0.6		# cooldown in seconds between dashes
const DASH_DECEL				= 70		# how fast dash decelerates each frame
const RESPAWN_CD				= 1.5		# cooldown in seconds to respawn

const MAX_HP					= 100		# do i really need to explain what this represents?


# variables that are essential to gameplay
var score						= 0					# goes up when collecting coins
var movespeed					= MOVESPEED_DEFAULT	# added to player's x-pos every frame
var velocity 					= Vector2() 		# needed for physics engine
var facing_right 				= true				# direction player is facing
var dead						= false				# whether player is dead

var dashing						= false				# whether or not player is dashing
var can_dash					= false				# whether or not dash is on cooldown
var can_double_jump				= false				# whether double jump is enabled or not
var has_double_jumped			= false				# if player has double jumped and hasn't touched ground
var has_speed_boost				= false				# if speed boost is in effect

var dash_timer					= Timer.new()
var respawn_timer				= Timer.new()


func enable_dash():
	# @Yong - GUI update should replace this line
	can_dash = true
	$Interface/CanvasLayer/DashProgress.value = 100

func respawn():
	facing_right = true
	_sprite.set_flip_h(false)
	position.x = ORIGIN_X
	position.y = ORIGIN_Y
	dead = false
	velocity.y = 0
	#$Interface/BarContainers/LifeBar/LifeProgress.value = 100
	
func jump():
	_jump_particle.restart()
	_jump_sound.play()
	velocity.y = JUMPIMPULSE


# Called when the node enters the scene tree for the first time.
func _ready():
	respawn()
	score = 0
	_sprite.play("idle")
	
	dash_timer.connect("timeout", self, "enable_dash")
	dash_timer.wait_time = DASH_CD
	dash_timer.set_one_shot(true)
	self.add_child(dash_timer)
	
	respawn_timer.connect("timeout", self, "respawn")
	respawn_timer.wait_time = RESPAWN_CD
	respawn_timer.set_one_shot(true)
	self.add_child(respawn_timer)
	
func _process(_delta):
	pass

func _physics_process(_delta):
	# on floor
	if is_on_floor():
		# having an x-velocity high enough to move the player into the floor 
		# each frame is needed for move_and_slide() to work properly.
		# values between 0.1 and 2.9 produced inconsistent results, so that's
		# why it's set to 3.
		velocity.y = 3
		has_double_jumped = false
		
	# successful jump conditions
	if is_on_floor() and Input.is_action_just_pressed("move_jump") and not dashing:
		jump()
		
	# mid-air conditions
	if not is_on_floor():
		if velocity.y <= 0:
			_sprite.play("jump")
		if velocity.y > 0:
			_sprite.play("fall")
			
		# double jump
		if can_double_jump and not has_double_jumped and Input.is_action_just_pressed("move_jump") and not dashing:
			_flap_sound.play()
			jump()
			has_double_jumped = true
		
		# dashing disables gravity when active
		if not dashing:
			velocity.x *= INAIR_SPEED
			velocity.y += GRAVITY
			
			# If the spacebar is released mid-jump, kill all vertical velocity
			# by 90%. This gives the illusion of a "shorter" jump.
			if Input.is_action_just_released("move_jump") and velocity.y < 0:
				velocity.y *= 0.1

	# Successful dash conditions.
	if Input.is_action_just_pressed("move_dash") and can_dash and not dead:
		_dash_sound.play()
		
		# ensures that dash particles travel in the same direction as player.
		# It looks better than having them go the opposite way, not sure why.
		if facing_right:
			# as you can see here, OOP is not verbose at all :)
			_dash_particle.process_material.initial_velocity = DASH_PARTICLE_VELOCITY
		else:
			# probably a more efficient way to do this but I'm really tired rn
			_dash_particle.process_material.initial_velocity = -DASH_PARTICLE_VELOCITY
		_dash_particle.restart()
		
		velocity.y = 3 # needed for same reasons stated in the first if statement
		dashing = true # blah blah blah
		
		# these two blocks should be self explanatory, lol
		if facing_right:
			velocity.x = DASHIMPULSE
		else:
			velocity.x = -DASHIMPULSE
		
		can_dash = false
		$Interface/CanvasLayer/DashProgress.value = 0
		dash_timer.start()
	
	# There's probably a way to do this next part without needing 2 nearly
	# identical blocks of code, but I have no idea what that would be.
	
	# if moving right and not dashing
	if Input.is_action_pressed("move_right") and not dashing and not dead:
		if is_on_floor():
			_sprite.play("walk")
		velocity.x = movespeed
		
		# flip sprite if necessary
		if not facing_right:
			_sprite.set_flip_h(false)
			facing_right = true
	
	# if moving left and not dashing
	elif Input.is_action_pressed("move_left") and not dashing and not dead:
		if is_on_floor():
			_sprite.play("walk")
		velocity.x = movespeed * -1
		
		# flip sprite if necessary... again
		if facing_right:
			_sprite.set_flip_h(true)
			facing_right = false

	# if on ground and standing still
	elif not dashing and is_on_floor():
		velocity.x = 0
		_sprite.play("idle")
		
	# runs if player is currently dashing, whether or not on ground
	if dashing:
		# same animation as walking, just with a faster framerate
		if is_on_floor():
			_sprite.play("dash")
		else:
			# no gravity when dashing in mid-air
			velocity.y = 0
		
		# dash slows down each frame until it reaches walking speed, instead of 0
		# this lets you seamlessly go from dashing into walking,
		# and also makes the dash feel snappier.
		if velocity.x > movespeed:
			velocity.x -= DASH_DECEL
		elif velocity.x < -movespeed:
			velocity.x += DASH_DECEL
		else:
			dashing = false
			
	# teleports player back to origin if they fall into water
	# no point in using a hitbox if the water is just a straight line,
	# more efficient to just do a quick coordinate check
	if position.y > 850:
		has_double_jumped = true # can't double-jump out of water
		if not dead:
			velocity.y = 0
			_splash_particle.restart()
			_splash_sound.play()
			dead = true
			Global.lose_life()
			respawn_timer.start()
		velocity.y *= WATER_SPEED
		
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Feather_body_entered(_body):
	__feather.queue_free()
	_jump_particle.restart()
	_flap_sound.play()
	can_double_jump = true

func _on_Boot_body_entered(_body):
	$Interface/CanvasLayer/DashProgress.value = 100
	__boot.queue_free()
	_jump_particle.restart()
	_dash_sound.play()
	can_dash = true

func _on_Coin_body_entered(body):
	score = score + 1
	$Interface/CanvasLayer/CoinCounter/Number.text = str(score)

func _on_BigCoin_body_entered(body):
	score = score + 5
	$Interface/CanvasLayer/CoinCounter/Number.text = str(score)
