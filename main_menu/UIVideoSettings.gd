extends Control

signal apply_button_pressed(settings)
signal cancel_button_pressed

var _settings := {resolution = Vector2(1920, 1080), fullscreen = false, vsync = false}

func init(settings: Dictionary):
	# Get our current settings from the OS
	_settings.resolution = settings.resolution
	_settings.fullscreen = settings.fullscreen
	_settings.vsync = settings.vsync
	
	# Update our UI
	$VBoxContainer/UIResolutionSelector.set_selected_resolution(_settings.resolution)
	$VBoxContainer/UIFullscreenCheckbox.enabled = _settings.fullscreen
	$VBoxContainer/UIVsyncCheckbox.enabled = _settings.vsync

func apply_settings():
	emit_signal("apply_button_pressed", _settings)

func _on_ApplyButton_pressed():
	apply_settings()


func _on_UIResolutionSelector_resolution_changed(new_resolution):
	_settings.resolution = new_resolution


func _on_UIFullscreenCheckbox_toggled(is_button_pressed):
	_settings.fullscreen = is_button_pressed


func _on_UIVsyncCheckbox_toggled(is_button_pressed):
	_settings.vsync = is_button_pressed


func _on_CancelButton_pressed():
	emit_signal("cancel_button_pressed")
