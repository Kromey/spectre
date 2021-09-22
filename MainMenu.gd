extends Control

onready var video_settings = VideoSettings.new()
onready var video_settings_ui = $UIVideoSettings
onready var buttons = $MenuContainer/ButtonsContainer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	video_settings_ui.visible = false
	video_settings.load_from_file()
	video_settings.apply_settings(get_tree())
	video_settings_ui.init(video_settings.to_dict())
	
	Game.current_state = Game.State.MainMenu

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if video_settings_ui.visible:
			# Cancel any changes/reset the UI
			video_settings_ui.init(video_settings.to_dict())
			toggle_video_settings_panel(false)
		else:
			get_tree().quit()
	if event.is_action_pressed("ui_accept") and video_settings_ui.visible:
		video_settings_ui.apply_settings()

func toggle_video_settings_panel(state: bool):
	if !video_settings_ui:
		yield(self, "ready")
	
	video_settings_ui.visible = state
	
	for button in buttons.get_children():
		button.disabled = state

func update_settings(settings: Dictionary) -> void:
	if !video_settings:
		yield(self, "ready")
	
	video_settings.from_dict(settings)
	video_settings.save()
	
	video_settings.apply_settings(get_tree())

func _on_StartGame_pressed():
	Game.current_state = Game.State.LoadingGame


func _on_Quit_pressed():
	get_tree().quit()


func _on_UIVideoSettings_apply_button_pressed(settings):
	update_settings(settings)
	toggle_video_settings_panel(false)


func _on_UIVideoSettings_cancel_button_pressed():
	# Cancel any changes/reset the UI
	video_settings_ui.init(video_settings.to_dict())
	toggle_video_settings_panel(false)


func _on_Settings_pressed():
	toggle_video_settings_panel(true)


func _on_About_pressed():
	$Credits.roll()
