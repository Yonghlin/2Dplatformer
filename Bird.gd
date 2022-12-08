extends KinematicBody2D

var navigation_agent : NavigationAgent2D

func _ready():
	navigation_agent = $NavigationAgent2D
	navigation_agent.connect("velocity_computed", self, "_on_velocity_computed")
	pass

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
		
	var targetpos = navigation_agent.get_next_location()
	var direction = global_position.direction_to(targetpos)
	
	if direction.x <= 0:
		get_node("AnimatedSprite").set_flip_h(true)
	elif direction.x > 0:
		get_node("AnimatedSprite").set_flip_h(false)
	
	var velocity = direction * navigation_agent.max_speed
	
	move_and_slide(velocity)

func _on_velocity_computed(velocity):
	pass

func _on_Timer_timeout():
	navigation_agent.set_target_location(get_global_mouse_position())
	pass
