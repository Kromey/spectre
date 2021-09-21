extends Control

signal apply_button_pressed(settings)

var _settings := {resolution = Vector2(1920, 1080), fullscreen = false, vsync = false}

func _ready():
	# Get our current settings from the OS
	_settings.resolution = OS.window_size
	_settings.fullscreen = OS.window_fullscreen
	_settings.vsync = OS.vsync_enabled
	
	# Update our UI
	$VBoxContainer/UIResolutionSelector.set_selected_resolution(_settings.resolution)
	$VBoxContainer/UIFullscreenCheckbox.enabled = _settings.fullscreen
	$VBoxContainer/UIVsyncCheckbox.enabled = _settings.vsync
	
	# Ensure any changes made (e.g. coercing resolution) are applied
	emit_signal("apply_button_pressed", _settings)

func _on_ApplyButton_pressed():
	emit_signal("apply_button_pressed", _settings)


func _on_UIResolutionSelector_resolution_changed(new_resolution):
	_settings.resolution = new_resolution


func _on_UIFullscreenCheckbox_toggled(is_button_pressed):
	_settings.fullscreen = is_button_pressed


func _on_UIVsyncCheckbox_toggled(is_button_pressed):
	_settings.vsync = is_button_pressed
