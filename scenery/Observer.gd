extends Spatial

var speed := 2.0
var velocity := Vector3.ZERO
var turn_rate := 0.25
var destination := Vector3.ZERO
var altitude := 5.0
var target = null

func _ready():
	randomize()
	
	var angle = rand_range(0, 2 * PI)
	var dist = rand_range(75, 120)
	
	translate(Vector3.FORWARD.rotated(Vector3.UP, angle) * dist)
	global_transform.origin.y = altitude
	look_at(Vector3.ZERO, Vector3.UP)
	new_destination()

func _physics_process(delta):
	if !is_instance_valid(target) || global_transform.origin.distance_to(destination) < 15:
		new_destination()
	
	var want = global_transform.origin.direction_to(destination) * speed
	velocity = velocity.move_toward(want, turn_rate * delta).normalized() * speed
	
	global_translate(-global_transform.basis.z * speed * delta)
	look_at(global_transform.origin + velocity, Vector3.UP)

func new_destination():
	var flags = get_tree().get_nodes_in_group("goals")
	if flags.size() > 0:
		if !is_instance_valid(target):
			var d = INF
			for flag in flags:
				var d2 = global_transform.origin.distance_to(flag.global_transform.origin)
				if d2 < d:
					d = d2
					target = flag
		
		var angle = rand_range(0, 2 * PI)
		var dist = rand_range(0, 25)
		
		destination = target.global_transform.origin + Vector3.FORWARD.rotated(Vector3.UP, angle) * dist
		destination.y = altitude
	else:
		destination = global_transform.origin + velocity
