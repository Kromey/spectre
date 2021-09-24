extends Spatial

var speed := 2.0
var transit_accel := 25.0
var velocity := Vector3.ZERO
var turn_rate := 0.25
var destination := Vector3.ZERO
var altitude := 5.0
var target = null

var current_state setget set_state

const BOMB = preload("res://scenery/MineBomb.tscn")
onready var bomb_from = $BombPos

enum State {
	Arriving,
	Traveling,
	Observing,
	Evacuating,
}

func _ready():
	randomize()
	
	# Where in the infinite void do we start from?
	var angle = rand_range(0, 2 * PI)
	var dist = 350 # Very very far away
	var start = Vector3.FORWARD.rotated(Vector3.UP, angle) * dist
	# Set our altitude
	start += Vector3.UP * altitude
	
	# Set our spawn location
	translate(start)
	look_at(Vector3.UP * altitude, Vector3.UP)
	
	# How far from the center of the map we arrive at
	var arrival_dist = rand_range(25, 75)
	
	# Calculate initial speed so that we decelerate by the time we reach our arrival_dist
	var ispeed = sqrt(pow(speed, 2) + 2 * transit_accel * (dist - arrival_dist))
	velocity = -global_transform.basis.z * ispeed
	
	set_state(State.Arriving)

func _physics_process(delta):
	match current_state:
		State.Arriving:
			velocity -= velocity.normalized() * transit_accel * delta
			
			if velocity.length() < speed + transit_accel * delta:
				# Within ~1 frame of arrival -- arrive!
				set_state(State.Observing)
			
		State.Traveling, State.Observing:
			var dist = global_transform.origin.distance_to(destination)
			
			if !is_instance_valid(target) || global_transform.origin.distance_to(destination) < 15:
				new_destination()
			elif dist > 55:
				set_state(State.Traveling)
			else:
				set_state(State.Observing)
			
			var direction = global_transform.origin.direction_to(destination)
			var vel = velocity.normalized()
			velocity = vel.slerp(direction, turn_rate * delta)
			velocity *= speed
			
			continue
			
		State.Observing:
			if randf() < 0.3 * delta:
				drop_da_bomb()
			
		State.Traveling:
			velocity *= 3
			
		State.Evacuating:
			velocity += velocity.normalized() * transit_accel * delta
			
			if global_transform.origin.length() > 250:
				queue_free()
	
	global_translate(velocity * delta)
	look_at(global_transform.origin + velocity, Vector3.UP)

func set_state(state):
	if current_state == state:
		return
	
	match state:
		State.Observing:
			$LeftLight.show()
			$RightLight.show()
		_:
			$LeftLight.hide()
			$RightLight.hide()
	
	current_state = state

func drop_da_bomb():
	var bomb = BOMB.instance()
	bomb.global_transform = bomb_from.global_transform
	bomb.rotate_x(rand_range(0, 2 * PI))
	bomb.rotate_y(rand_range(0, 2 * PI))
	bomb.rotate_z(rand_range(0, 2 * PI))
	
	bomb.velocity = velocity
	
	get_parent().add_child(bomb)

func new_destination():
	if current_state == State.Evacuating:
		return
	
	var flags = get_tree().get_nodes_in_group("goals")
	if flags.size() > 0:
		if !is_instance_valid(target):
			# Find flag closest to our current direction of travel
			var face = -global_transform.basis.z
			var angle = 3 * PI
			for flag in flags:
				var flag_angle = face.angle_to(flag.global_transform.origin)
				if flag_angle < angle:
					target = flag
					angle = flag_angle
#			flags.shuffle()
#			target = flags[0]
		
		var angle = rand_range(0, 2 * PI)
		var dist = rand_range(0, 25)
		
		destination = target.global_transform.origin + Vector3.FORWARD.rotated(Vector3.UP, angle) * dist
		destination.y = altitude
	else:
		destination = global_transform.origin + velocity
