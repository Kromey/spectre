extends Spatial

export var BULLET_VELOCITY = Vector3.FORWARD
export var BULLET_TIME = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(BULLET_TIME)
	timer.connect("timeout", self, "queue_free")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
