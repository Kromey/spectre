extends Control

onready var video_settings = VideoSettings.new()
onready var video_settings_ui = $UIVideoSettings
onready var buttons = $MenuContainer/ButtonsContainer

const CREDITS := [
	["Game Design & Programming", "Travis Veazey",],
	["3D Models & Textures", "Travis Veazey",],
]
const CREDITS_LINE_TIME := 0.3
const CREDITS_TITLE_COLOR := Color.blueviolet
const CREDITS_SPEED := 125

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$CreditsLabel.hide()
	
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

func roll_credits():
	get_tree().call_group("running_credits", "queue_free")
	
	var timer = Timer.new()
	timer.wait_time = CREDITS_LINE_TIME
	add_child(timer)
	
	var label = $CreditsLabel
	var title: bool
	
	var scroll_time = OS.window_size.y / CREDITS_SPEED
	
	for section in CREDITS:
		title = true
		
		for line in section:
			var l = label.duplicate()
			l.rect_position.x = 25
			l.rect_position.y = OS.window_size.y
			l.text = line
			l.show()
			l.add_to_group("running_credits")
			if title:
				l.add_color_override("font_color", CREDITS_TITLE_COLOR)
			add_child(l)
			
			var tween = Tween.new()
			tween.interpolate_property(l, "rect_position", l.rect_position, Vector2(25, 0), scroll_time)
			tween.interpolate_property(l, "modulate", l.modulate, Color(1, 1, 1, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 3.5)
			l.add_child(tween)
			tween.start()
			var __ = tween.connect("tween_all_completed", l, "queue_free")
			
			title = false
			
			timer.start()
			yield(timer, "timeout")
		
		timer.start()
		yield(timer, "timeout")

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
	roll_credits()
