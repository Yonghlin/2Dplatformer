extends HBoxContainer

func initialize(maximum):
	$LifeProgress.max_value = maximum

func _on_Interface_health_changed(health):
	$LifeProgress.value = health
