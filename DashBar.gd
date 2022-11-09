extends HBoxContainer

var maximum_dash = 100
var current_dash = 0

func initialize(maximum):
	maximum_dash = maximum
	$DashProgress.max_value = maximum

func _on_Interface_dash_changed(dash):
	current_dash = dash
