extends AudioStreamPlayer2D

onready var _player = get_node("/root/Node2D/Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = _player.position.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _player.position.x >= 350 and _player.position.x < 2900:
		position.x = _player.position.x
