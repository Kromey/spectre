extends Control

onready var video_settings = $UIVideoSettings
onready var buttons = $MenuContainer/ButtonsContainer

func _ready():
	video_settings.visible = false
	Game.current_state = Game.State.MainMenu

func toggle_video_settings_panel(state: bool):
	if !video_settings:
		yield(self, "ready")
	
	video_settings.visible = state
	
	for button in buttons.get_children():
		button.disabled = state

func update_settings(settings: Dictionary) -> void:
	OS.window_fullscreen = settings.fullscreen
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, settings.resolution
	)
	OS.set_window_size(settings.resolution)
	OS.vsync_enabled = settings.vsync
	
	OS.center_window()

func _on_StartGame_pressed():
	Game.current_state = Game.State.LoadingGame


func _on_Quit_pressed():
	get_tree().quit()


func _on_UIVideoSettings_apply_button_pressed(settings):
	update_settings(settings)
	toggle_video_settings_panel(false)


func _on_Settings_pressed():
	toggle_video_settings_panel(true)
