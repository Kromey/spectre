extends Control

func _ready():
	Game.current_state = Game.State.MainMenu

func _on_StartGame_pressed():
	Game.current_state = Game.State.LoadingGame


func _on_Quit_pressed():
	get_tree().quit()
