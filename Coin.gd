extends Area2D

onready var _sprite = $AnimatedSprite

var despawn_timer = Timer.new()

func despawn():
	queue_free()

func _ready():
	_sprite.play("spin")
	
	despawn_timer.connect("timeout", self, "despawn")
	despawn_timer.wait_time = 1
	despawn_timer.set_one_shot(true)
	self.add_child(despawn_timer)
	
func _on_Coin_body_entered(body):
	_sprite.play("fade")
	despawn_timer.start()
