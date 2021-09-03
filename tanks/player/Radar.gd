extends MarginContainer

var player

const Icon = preload("res://tanks/player/radar/RadarIcon.tscn")
const EnemyIcon = preload("res://tanks/player/radar/EnemyIcon.tscn")
const FeatureIcon = preload("res://tanks/player/radar/FeatureIcon.tscn")
const PickupIcon = preload("res://tanks/player/radar/PickupIcon.tscn")
const FlagIcon = preload("res://tanks/player/radar/FlagIcon.tscn")
const FlagPointer = preload("res://tanks/player/radar/FlagPointer.tscn")
const MissileIcon = preload("res://tanks/player/radar/MissileIcon.tscn")

var zoom = 1.5
var center := Vector2.ZERO

func _ready():
	# Disable physics processing until we've set up our radar
	set_physics_process(false)

func refresh():
	var p = get_tree().get_nodes_in_group("player")
	if p.size() > 0:
		player = p[0]
	else:
		print("Failed to initialize radar, retrying...")
		call_deferred("refresh")
		return
	
	# Flush our radar
	for child in $RadarIcons.get_children():
		$RadarIcons.remove_child(child)
		child.queue_free()
	
	center = rect_size / 2.0
	
	# NB: Order matters! First icons added will be underneath later icons
	
	for feature in get_tree().get_nodes_in_group("map_features"):
		add_icon(FeatureIcon, feature)
	
	for pickup in get_tree().get_nodes_in_group("pickups"):
		add_icon(PickupIcon, pickup)
	
	for flag in get_tree().get_nodes_in_group("goals"):
		add_icon(FlagIcon, flag)
		add_icon(FlagPointer, flag)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		add_icon(EnemyIcon, enemy)
	
	for missile in get_tree().get_nodes_in_group("missiles"):
		add_icon(MissileIcon, missile)
	
	# All good now, enable physics processing
	set_physics_process(true)

func add_icon(packed_icon: PackedScene, node: Spatial):
	var icon = packed_icon.instance()
	icon.me = node
	icon.center = center
	$RadarIcons.add_child(icon)
	icon.update_pos(player.global_transform, zoom)

func _physics_process(_delta):
	get_tree().call_group("radar_icons", "update_pos", player.global_transform, zoom)

func _input(event):
	if event.is_action_pressed("radar_zoom_in"):
		zoom += 0.5
	if event.is_action_pressed("radar_zoom_out"):
		zoom -= 0.5
	
	var max_zoom = 5
	zoom = clamp(zoom, 0.5, max_zoom)
	$CanvasLayer/ZoomLevel.text = "x%s" % str((max_zoom - zoom + 0.5) * 2)
