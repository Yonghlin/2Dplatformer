extends Control

signal health_changed(health)
signal coins_changed(count)
signal dash_changed(dash)

func _on_Health_health_changed(health):
	emit_signal("health_changed", health)
	
func _on_Purse_coins_changed(count):
	emit_signal("coins_changed", count)

func _on_Dash_dash_changed(dash):
	emit_signal("dash_changed", dash)
