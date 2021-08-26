extends Node

var player_score = 0
var player_kills = 0

func add_to_score(change):
	player_score += change
	get_tree().call_group("player", "update_score", player_score)

func add_to_kills(change):
	player_kills += change
	get_tree().call_group("player", "update_kills", player_kills)
