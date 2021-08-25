extends Node

var player_score = 0

func add_to_score(change):
	player_score += change
	get_tree().call_group("player", "update_score", player_score)
