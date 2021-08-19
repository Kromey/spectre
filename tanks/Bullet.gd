extends Spatial

export var BULLET_SPEED = 12.0
export var BULLET_TIME = 4.0
export var BULLET_DAMAGE = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(BULLET_TIME)
	timer.connect("timeout", self, "queue_free")

func _physics_process(delta):
	global_translate(transform.basis.z * -BULLET_SPEED * delta)
