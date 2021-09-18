extends Control

func _ready():
	Game.current_state = Game.State.MainMenu

func _on_StartGame_pressed():
	Game.current_state = Game.State.LoadingGame
