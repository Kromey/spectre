extends KinematicBody

var falling = 0.0
const GRAVITY = 2

var damage = 0
export(int) var MAX_DAMAGE = 1

var velocity = Vector3.ZERO
export(float) var MAX_SPEED = 10
export(float) var ACCEL = 9 # Acceleration per second

var angular_velocity = 0
export(float) var TURN_RATE = PI / 2.0
export(float) var TURN_ACCEL = 8

export(float) var MAX_AMMO = 3
export(float) var FIRE_RATE = 1.5
export(float) var RELOAD_TIME = 3
export(float) var GUN_RANGE = 30
export(float) var BULLET_SPEED = 0
export(int) var GUN_DAMAGE = 1
var ammo = 0
var reloading = false

export(float) var TRAUMA_DECAY = 0.8
export(float) var max_offset = 0.3

var trauma = 0.0
var trauma_power = 2


enum Direction {
	FORWARD = -1,
	BACK = 1,
	LEFT = 1,
	RIGHT = -1
}

const Bullet = preload("res://tanks/Bullet.tscn")
const BOOM = preload("res://tanks/BoomTheTank.tscn")

onready var ShootSound = find_node("ShootAudio")

signal damage_changed
signal ammo_changed
signal reloading
signal dead

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if BULLET_SPEED <= 0:
		BULLET_SPEED = MAX_SPEED + 2
	reload_immediate()

func _physics_process(delta):
	velocity += Vector3.DOWN * GRAVITY * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if translation.y < -5:
		take_damage(Vector3.DOWN, MAX_DAMAGE * MAX_DAMAGE)
	
	if trauma:
		trauma = max(trauma - TRAUMA_DECAY * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	translation += global_transform.basis.x * max_offset * amount * rand_range(-1, 1)

func drive(direction, delta):
	if is_on_floor():
		var hvel = velocity
		hvel.y = 0
		
		var dir = transform.basis.z * clamp(direction, -1.0, 1.0)
		
		var target = dir * MAX_SPEED
		
		var accel = ACCEL
		if dir.dot(hvel) <= 0:
			accel *= 2
		
		hvel = hvel.move_toward(target, accel * delta)
		velocity.x = hvel.x
		velocity.z = hvel.z

func turn(direction, delta):
	if is_on_floor():
		var turn_input = direction * TURN_RATE * delta
		
		var accel = TURN_ACCEL * delta
		if abs(turn_input) < abs(angular_velocity):
			# Stop turning twice as fast as we started
			accel *= 2
		
		angular_velocity = lerp(angular_velocity, turn_input, accel)
	
	rotate_y(angular_velocity)

func shoot():
	if ammo > 0 and !reloading and $FireRate.is_stopped():
		$FireRate.start(FIRE_RATE)
		ammo -= 1
		emit_signal("ammo_changed", ammo)
		
		var bullet = Bullet.instance()
		bullet.BULLET_TIME = GUN_RANGE / BULLET_SPEED
		bullet.BULLET_SPEED = BULLET_SPEED
		bullet.BULLET_DAMAGE = GUN_DAMAGE
		bullet.shooter = self
		bullet.global_transform = $BulletSpawn.global_transform
		get_tree().root.add_child(bullet)
		
		$MuzzleFlare.restart()
		ShootSound.play()
		
		if ammo <= 0:
			reload()

func reload():
	if !reloading:
		emit_signal("reloading", true)
		reloading = true
		var _e = get_tree().create_timer(RELOAD_TIME).connect("timeout", self, "reload_immediate")

func reload_immediate():
	ammo = MAX_AMMO
	emit_signal("ammo_changed", ammo)
	reloading = false
	emit_signal("reloading", false)
	# Ensure reloading clears fire rate timer
	$FireRate.stop()

func take_damage(_force, amount, shooter = null):
	damage = clamp(damage + amount, 0, MAX_DAMAGE)
	emit_signal("damage_changed", damage, MAX_DAMAGE)
	
	if damage >= MAX_DAMAGE:
		die(shooter)
	else:
		trauma = min(trauma + amount / 2.0, 1.0)
		$HitSound.play()

func repair_damage(amount):
	take_damage(0, -amount)

func die(killer):
	var boom = BOOM.instance()
	boom.translation = translation
	get_parent().add_child(boom)
	
	emit_signal("dead", killer)
	queue_free()
