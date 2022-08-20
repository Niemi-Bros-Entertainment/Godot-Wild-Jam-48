'UITitleScreen'
extends Control

signal settings_query

onready var titleOptions = $CanvasLayer/VBoxContainer


func _on_SettingsButton_pressed():
	SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
	emit_signal("settings_query")


func _on_UISettings_settings_close():
	titleOptions.visible = true
	titleOptions.get_child(0).grab_focus()


func _on_UISettings_settings_open():
	titleOptions.visible = false
