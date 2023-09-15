extends Node


func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	find_child("Score").text = "Score: %s" % Game.player_score


func _on_NewGame_pressed():
	var e = get_tree().reload_current_scene()
	assert(e == OK)


func _on_MainMenu_pressed():
	get_tree().paused = false
	Game.set_state(Game.State.MainMenu)


func _on_Quit_pressed():
	get_tree().quit()
