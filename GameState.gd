extends Node

var player_score = 0
var player_kills = 0

var level = 0

func _ready():
	reset_stats()

func reset_stats():
	# Use the add_to_* functions to properly dispatch signals
	add_to_score(-player_score)
	add_to_kills(-player_kills)
	set_level(1)

func set_level(new_level):
	level = new_level
	get_tree().call_group("player", "update_level", level)

func level_up():
	set_level(level + 1)

func add_to_score(change):
	player_score += change
	get_tree().call_group("player", "update_score", player_score)

func add_to_kills(change):
	player_kills += change
	get_tree().call_group("player", "update_kills", player_kills)
