extends Control

signal apply_button_pressed(settings)

var _settings := {resolution = Vector2(1920, 1080), fullscreen = false, vsync = false}


func _on_ApplyButton_pressed():
	emit_signal("apply_button_pressed", _settings)


func _on_UIResolutionSelector_resolution_changed(new_resolution):
	_settings.resolution = new_resolution


func _on_UIFullscreenCheckbox_toggled(is_button_pressed):
	_settings.fullscreen = is_button_pressed


func _on_UIVsyncCheckbox_toggled(is_button_pressed):
	_settings.vsync = is_button_pressed
