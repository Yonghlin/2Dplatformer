# Author: Michael Frank

extends KinematicBody2D

# Child node imports.
# !! IMPORTANT !!
# you should never call the get_node() function inside the _process() function,
# as it will actively search the path of each node for every single frame.
# this needlessly wastes CPU, so it's better to store the results in variables
# if you will be referencing them constantly.
const bullet_path				= preload("res://Bullet.tscn")

onready var _sprite				= get_node("./AnimatedSprite")
onready var _attack_area		= get_node("./AttackArea")
onready var _dash_particle		= get_node("./Particle/DashParticle")
onready var _jump_particle		= get_node("./Particle/JumpParticle")
onready var _splash_particle	= get_node("./Particle/SplashParticle")
onready var _attack_particle	= get_node("./Particle/AttackParticle")

onready var _dash_sound			= get_node("./Sound/DashSound")
onready var _jump_sound			= get_node("./Sound/JumpSound")
onready var _splash_sound		= get_node("./Sound/SplashSound")
onready var _flap_sound			= get_node("./Sound/FlapSound")
onready var _sword_slash_sound	= get_node("./Sound/SwordSlashSound")
onready var _gun_sound			= get_node("./Sound/GunSound")
onready var _click_sound		= get_node("./Sound/ClickSound")

# Item node imports
onready var __feather			= get_node("../World/Items/Feather")
onready var __boot				= get_node("../World/Items/Boot")
onready var __coin				= get_node("../World/Items/Coin")

# Constants that are essential to physics and gameplay mechanics
const ORIGIN_X					= 350		# player's starting x-coord
const ORIGIN_Y					= 350		# player's starting y-coord

const GRAVITY					= 70		# added to player's y-vel every frame
const MOVESPEED_DEFAULT			= 400		# player's default movespeed
const SPEEDBOOST_MULT			= 1.5		# `movespeed` *= this when player has speedboost powerup

const JUMPIMPULSE				= -1100		# added to player's y-vel on successful jump
const INAIR_SPEED				= 0.85		# x-vel is multiplied by this when in midair
const WATER_SPEED				= 0.75		# y-vel is multiplied by this when "underwater"

const DASHIMPULSE 				= 1300 		# added to player's x-vel on successful dash
const DASH_PARTICLE_VELOCITY	= -8 		# reflects which direction player is facing
const DASH_CD					= 0.6		# cooldown in seconds between dashes
const DASH_DECEL				= 70		# how fast dash decelerates each frame
const RESPAWN_CD				= 1.5		# cooldown in seconds to respawn
const ATTACK_CD					= 0.25		# cooldown in seconds to attack
const SHOOT_CD					= 0.3			# cooldown in seconds to shoot gun

const MAX_HP					= 100		# self-explanatory
const DEFAULT_AMMO				= 5
const MAX_AMMO					= 20

# variables that are essential to gameplay
var score						= 0					# goes up when collecting coins
var ammo						= DEFAULT_AMMO		# how many bullets player can shoot
var movespeed					= MOVESPEED_DEFAULT	# added to player's x-pos every frame
var velocity 					= Vector2() 		# needed for physics engine
var facing_right 				= true				# direction player is facing
var dead						= false				# whether player is dead

# MOVEMENT STATES
var dashing						= false				# whether or not player is dashing
var can_dash					= false				# whether or not dash is on cooldown
var can_double_jump				= false				# whether double jump is enabled or not
var has_double_jumped			= false				# if player has double jumped and hasn't touched ground
var has_wall_jump				= false
var attacking					= false				# if player attack animation currently playing
var shooting					= false				# if shooting animation currently playing

# timers
var dash_timer					= Timer.new()		# dash cooldown timer
var respawn_timer				= Timer.new()		# respawn delay timer
var attack_timer				= Timer.new()		# attack cooldown timer
var shoot_timer					= Timer.new()		# shooting cooldown timer


# Helper functions
func enable_dash():
	# @Yong - GUI update should go here
	can_dash = true
	$Interface/CanvasLayer/DashProgress.value = 100

func respawn():
	facing_right = true
	_sprite.set_flip_h(false)
	position.x = ORIGIN_X
	position.y = ORIGIN_Y
	dead = false
	velocity.y = 0
	ammo = DEFAULT_AMMO
	$Interface/BarContainers/LifeBar/LifeProgress.value = 100
	
func jump():
	_jump_particle.restart()
	_jump_sound.play()
	velocity.y = JUMPIMPULSE
	
func start_attack():
	attacking = true
	
	if not facing_right:
		_attack_area.position.x = -38
	else:
		_attack_area.position.x = 38
	_attack_area.visible = true
	
	_sprite.play("attack")
	_sword_slash_sound.play()
	_attack_particle.restart()
	attack_timer.start()
	
func start_shoot():
	if (ammo > 0):
		shooting = true;
		_sprite.play("shoot")
		_gun_sound.play()
		shoot_timer.start()
		ammo -= 1
		
		var bullet = bullet_path.instance()
		get_parent().add_child(bullet)
		bullet.position = $Position2D.global_position
		
		if not facing_right:
			bullet.direction = -1
	

	else:
		_click_sound.play()
	
func end_attack():
	attacking = false
	_attack_area.visible = false

func end_shoot():
	shooting = false
	$Sound/ReloadSound.play()


# Called when the node enters the scene tree for the first time.
func _ready():
	respawn()
	score = 0
	_sprite.play("idle")
	#_attack_area.visible = false
	
	dash_timer.connect("timeout", self, "enable_dash")
	dash_timer.wait_time = DASH_CD
	dash_timer.set_one_shot(true)
	self.add_child(dash_timer)
	
	respawn_timer.connect("timeout", self, "respawn")
	respawn_timer.wait_time = RESPAWN_CD
	respawn_timer.set_one_shot(true)
	self.add_child(respawn_timer)
	
	attack_timer.connect("timeout", self, "end_attack")
	attack_timer.wait_time = ATTACK_CD
	attack_timer.set_one_shot(true)
	self.add_child(attack_timer)
	
	shoot_timer.connect("timeout", self, "end_shoot")
	shoot_timer.wait_time = SHOOT_CD
	shoot_timer.set_one_shot(true)
	self.add_child(shoot_timer)
	
	
	# temporary until John gets save system working
	if get_tree().current_scene.filename == "res://Level2.tscn":
		can_double_jump = true
	
	if get_tree().current_scene.filename == "res://Level3.tscn":
		can_double_jump = true
		can_dash = true
	
func _process(_delta):
	pass

func _physics_process(_delta):
	if is_on_floor():
		# having an x-velocity high enough to move the player into the floor 
		# each frame is needed for move_and_slide() to work properly.
		# values between 0.1 and 2.9 produced inconsistent results, so that's
		# why it's set to 3.
		velocity.y = 3
		has_double_jumped = false
		
	# successful jump conditions
	if Input.is_action_just_pressed("move_jump") and not dashing:
		if is_on_floor():
			jump()
		
		elif can_double_jump and not has_double_jumped and not is_on_floor():
			_flap_sound.play()
			jump()
			has_double_jumped = true
		
	# mid-air conditions
	

	# Successful dash conditions.
	if Input.is_action_just_pressed("move_dash") and can_dash and not dead and not attacking and not shooting:
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
		if is_on_floor() and not attacking and not shooting:
			_sprite.play("walk")
		velocity.x = movespeed
		
		# flip sprite if necessary
		if not facing_right:
			_sprite.set_flip_h(false)
			facing_right = true
	
	# if moving left and not dashing
	elif Input.is_action_pressed("move_left") and not dashing and not dead:
		if is_on_floor() and not attacking and not shooting:
			_sprite.play("walk")

		velocity.x = movespeed * -1
		
		# flip sprite if necessary... again
		if facing_right:
			_sprite.set_flip_h(true)
			facing_right = false
			

	# if on ground and standing still
	elif not dashing and is_on_floor() and not attacking and not shooting:
		velocity.x = 0
		_sprite.play("idle")
	
	
	if not is_on_floor():
		if not attacking and not shooting:
			if velocity.y <= 0:
				_sprite.play("jump")
			if velocity.y > 0:
				_sprite.play("fall")
		
		# dashing disables gravity when active
		if not dashing:
			velocity.x *= INAIR_SPEED
			velocity.y += GRAVITY
			
			# If the spacebar is released mid-jump, kill all vertical velocity
			# by 90%. This gives the illusion of a "shorter" jump.
			if Input.is_action_just_released("move_jump") and velocity.y < 0:
				velocity.y *= 0.1
				
				
	# attacking conditions
	if Input.is_action_just_pressed("attack") and not dashing and not attacking and not shooting and not dead:
		start_attack()
		
	if Input.is_action_just_pressed("shoot") and not dashing and not attacking and not shooting and not dead:
		start_shoot()
		
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


# collision detections.
# trying to detect collisions across different scenes is an absolute NIGHTMARE,
# and google offered no help at all. This is the method I came up with:
# - Each object has its own function for when the player enters
# - said object will perform necessary functions for itself (like despawning)
# - said object will then call these functions below from the player, depending
# - on what object the player entered.

# I tried using signals to do this, but it was buggy at best and was much harder
# to wrap one's head around.
func feather_entered():
	_jump_particle.restart()
	_flap_sound.play()
	can_double_jump = true

func boot_entered():
	$Interface/BarContainers/DashBar/DashProgress.value = 100
	_jump_particle.restart()
	_dash_sound.play()
	can_dash = true

func coin_entered():
	score = score + 1
	$Interface/CanvasLayer/CoinCounter/Number.text = str(score)

func big_coin_entered():
	score = score + 5
	$Interface/CanvasLayer/CoinCounter/Number.text = str(score)
