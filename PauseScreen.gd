extends Node

onready var video_settings = VideoSettings.new()
onready var video_settings_ui = $UIVideoSettings

func _ready():
	video_settings_ui.visible = false
	video_settings.load_from_file()
	video_settings_ui.init(video_settings.to_dict())

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	match Game.current_state:
		Game.State.Paused:
			if event.is_action_pressed("action_pause"):
				resume_game()
			elif event.is_action_pressed("ui_accept") and video_settings_ui.visible:
				video_settings_ui.apply_settings()

func toggle_video_settings_panel(state: bool):
	if !video_settings_ui:
		yield(self, "ready")
	
	video_settings_ui.visible = state

func update_settings(settings: Dictionary) -> void:
	if !video_settings:
		yield(self, "ready")
	
	video_settings.from_dict(settings)
	video_settings.save()
	
	video_settings.apply_settings(get_tree())

func resume_game():
	if Game.current_state == Game.State.Paused:
		get_tree().set_deferred("paused", false)
		
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		get_parent().remove_child(self)
		Game.current_state = Game.State.Running


func _on_Resume_pressed():
	resume_game()


func _on_Quit_pressed():
	get_tree().paused = false
	Game.set_state(Game.State.MainMenu)


func _on_Settings_pressed():
	toggle_video_settings_panel(true)


func _on_UIVideoSettings_apply_button_pressed(settings):
	update_settings(settings)
	toggle_video_settings_panel(false)


func _on_UIVideoSettings_cancel_button_pressed():
	# Cancel any changes/reset the UI
	video_settings_ui.init(video_settings.to_dict())
	toggle_video_settings_panel(false)


func _on_QuitProgram_pressed():
	get_tree().quit()
