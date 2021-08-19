extends Spatial

export var BULLET_SPEED = 12.0
export var BULLET_TIME = 4.0
export var BULLET_DAMAGE = 1.0

var hit_something = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(BULLET_TIME)
	timer.connect("timeout", self, "queue_free")
	$Area.connect("body_entered", self, "collided")

func _physics_process(delta):
	global_translate(transform.basis.z * -BULLET_SPEED * delta)

func collided(target):
	if !hit_something and target.has_method("take_damage"):
		target.take_damage(transform.basis.z * -BULLET_SPEED, BULLET_DAMAGE)
	
	hit_something = true
	queue_free()
