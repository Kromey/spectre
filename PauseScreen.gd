extends Node

func _enter_tree():
	print("Pause screen ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("action_pause"):
		resume_game()

func resume_game():
	get_tree().set_deferred("paused", false)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	get_parent().remove_child(self)


func _on_Resume_pressed():
	resume_game()


func _on_Quit_pressed():
	get_tree().paused = false
	Game.set_state(Game.State.MainMenu)
