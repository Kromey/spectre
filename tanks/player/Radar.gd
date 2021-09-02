extends MarginContainer

var player

const Icon = preload("res://tanks/player/radar/RadarIcon.tscn")
const EnemyIcon = preload("res://tanks/player/radar/EnemyIcon.tscn")
const FeatureIcon = preload("res://tanks/player/radar/FeatureIcon.tscn")
const PickupIcon = preload("res://tanks/player/radar/PickupIcon.tscn")
const FlagIcon = preload("res://tanks/player/radar/FlagIcon.tscn")

var zoom = 1.5
var center := Vector2.ZERO

func _ready():
	set_physics_process(false)
	call_deferred("initialize")

func initialize():
	var p = get_tree().get_nodes_in_group("player")
	if p.size() > 0:
		player = p[0]
	else:
		print("Failed to initialize radar, retrying...")
		call_deferred("initialize")
		return
	
	center = rect_size / 2.0
	print(rect_size, center)
	
	# NB: Order matters! First icons added will be underneath later icons
	
	for feature in get_tree().get_nodes_in_group("map_features"):
		add_icon(FeatureIcon, feature)
	
	for pickup in get_tree().get_nodes_in_group("pickups"):
		add_icon(PickupIcon, pickup)
	
	for flag in get_tree().get_nodes_in_group("goals"):
		add_icon(FlagIcon, flag)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		add_icon(EnemyIcon, enemy)
	
	set_physics_process(true)

func add_icon(packed_icon: PackedScene, node: Spatial):
	var icon = packed_icon.instance()
	icon.me = node
	icon.center = center
	add_child(icon)

func _physics_process(_delta):
	get_tree().call_group("radar_icons", "update_pos", player.global_transform, zoom)
