extends Area2D

onready var _sprite = $AnimatedSprite

var despawn_timer = Timer.new()

func despawn():
	queue_free()


func _ready():
	$AnimatedSprite.play("spin")
	despawn_timer.connect("timeout", self, "despawn")
	despawn_timer.wait_time = 0.4
	despawn_timer.set_one_shot(true)
	self.add_child(despawn_timer)
	
func _on_Coin_body_entered(body):
	# disable hitbox immediately, play fade animation and then despawn once done
	if body.is_in_group("Player"):
		body.coin_entered()
		
	$AnimatedSprite.play("fade")
	$PickupSound.play()
	remove_child($CollisionShape2D)
	despawn_timer.start()
