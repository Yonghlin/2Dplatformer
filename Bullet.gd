extends Area2D

const VELOCITY = 10

var direction = 1 # 1 = right, -1 = left

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += VELOCITY * direction 
	
func _on_Bullet_body_entered(body):
	if not body.is_in_group("Player"):
		$ThudSound.play()
		direction = 0
		yield($ThudSound, "finished") # wait for sound to finish before despawning
		queue_free() # despawn
