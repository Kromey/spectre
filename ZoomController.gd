extends Node

const ZOOM := preload("res://pickups/ZoomZoom.tscn")
const ZOOM_COUNT := 5

@export var MULTIPLIER: float = 3

var pool := []
var rng: RandomNumberGenerator


func _ready():
	for __ in ZOOM_COUNT:
		var zoom = ZOOM.instantiate()
		add_child(zoom)
		zoom.hide()
		var _e = zoom.connect("body_entered", Callable(self, "_on_zoom_pickup").bind(zoom))
		pool.append(zoom)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()

func spawn_zooms(min_dist = 30, from = Vector3.ZERO):
	var dist_sq = pow(min_dist, 2)
	
	if from == Vector3.ZERO and is_instance_valid(Game.world.player):
			from = Game.world.player.global_transform.origin
	
	for zoom in pool:
		var x = from.x
		var z = from.z
		zoom.position = Vector3(x, 0, z)
		
		while zoom.position.distance_squared_to(from) < dist_sq:
			x = rng.randf_range(-90, 90)
			z = rng.randf_range(-90, 90)
			zoom.position = Vector3(x, 0, z)
		
		zoom.show()

func _on_zoom_pickup(body, zoom: Node3D):
	print("Entered zoom!", zoom.position)
	if !'velocity' in body:
		prints(body, "does not have velocity")
		return
	
	$ZoomAccelerate.stop()
	
	body.velocity *= MULTIPLIER
	
	$ZoomAccelerate.position = zoom.position
	$ZoomAccelerate.play()
	
	zoom.hide()
