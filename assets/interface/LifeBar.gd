extends HBoxContainer

var maximum_health = 100
var current_health = 0

func initialize(maximum):
	maximum_health = maximum
	$LifeProgress.max_value = maximum

func _on_Interface_health_changed(health):
	current_health = health
