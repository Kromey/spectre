extends Node

const ZOOM := preload("res://pickups/ZoomZoom.tscn")
const ZOOM_COUNT := 5

export(float) var MULTIPLIER = 3

var pool := []
var rng: RandomNumberGenerator


func _ready():
	for __ in ZOOM_COUNT:
		var zoom = ZOOM.instance()
		add_child(zoom)
		zoom.hide()
		var _e = zoom.connect("body_entered", self, "_on_zoom_pickup", [zoom])
		pool.append(zoom)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()

func spawn_zooms(min_dist = 30, from = Vector3.ZERO):
	var dist_sq = pow(min_dist, 2)
	
	for zoom in pool:
		var x = from.x
		var z = from.z
		zoom.translation = Vector3(x, 0, z)
		
		while zoom.translation.distance_squared_to(from) < dist_sq:
			x = rng.randf_range(-90, 90)
			z = rng.randf_range(-90, 90)
			zoom.translation = Vector3(x, 0, z)
		
		zoom.show()

func _on_zoom_pickup(body, zoom: Spatial):
	print("Entered zoom!", zoom.translation)
	if !'velocity' in body:
		prints(body, "does not have velocity")
		return
	
	$ZoomAccelerate.stop()
	
	body.velocity *= MULTIPLIER
	
	$ZoomAccelerate.translation = zoom.translation
	$ZoomAccelerate.play()
	
	zoom.hide()
