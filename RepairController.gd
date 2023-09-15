extends Node

const REPAIR = preload("res://pickups/ArmorPickup.tscn")
const REPAIR_COUNT := 5

@export var repair_value: int = 2

var pool := []
var rng: RandomNumberGenerator


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for __ in REPAIR_COUNT:
		var repair = REPAIR.instantiate()
		add_child(repair)
		repair.hide()
		var _e = repair.connect("body_entered", Callable(self, "_on_repair_pickup").bind(repair))
		pool.append(repair)
		
		repair.rotate_y(rng.randf_range(0, PI))
		
		var tween = repair.get_node("Tween")
		tween.interpolate_property(repair, "rotation", repair.rotation, repair.rotation + Vector3.UP * 2 * PI, 4)
		tween.repeat = true
		tween.start()

func spawn_repairs(min_dist = 50, from = Vector3.ZERO):
	if from == Vector3.ZERO and is_instance_valid(Game.world.player):
			from = Game.world.player.global_transform.origin
	
	for repair in pool:
		move(repair, min_dist, from)

func move(repair: Node3D, min_dist: float, from: Vector3):
	var x = from.x
	var z = from.z
	repair.position = Vector3(x, 0, z)
	
	var dist_sq = pow(min_dist, 2)
	
	while repair.position.distance_squared_to(from) < dist_sq:
		x = rng.randf_range(-90, 90)
		z = rng.randf_range(-90, 90)
		
		repair.position = Vector3(x, 0, z)
	
	repair.show()

func _on_repair_pickup(body, repair):
	if !body.has_method("repair_damage"):
		return
	
	repair.hide()
	$RepairPickup.play()
	body.repair_damage(repair_value)
	move(repair, 25, repair.position)
