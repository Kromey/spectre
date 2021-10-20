extends "res://PauseScreen.gd"


func _enter_tree():
	find_node("Score").text = "Score: %s" % Game.player_score

func _on_Resume_pressed():
	var e = get_tree().reload_current_scene()
	assert(e == OK)
