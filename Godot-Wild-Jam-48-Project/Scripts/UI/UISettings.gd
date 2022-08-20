'UISettings'
extends Control

signal settings_open
signal settings_close

onready var tween :Tween = $Tween
onready var choicesParent = $VBoxContainer

var input_startPosX
var vBox_startPosX


func _ready():
	visible = false
	set_process_input(false)
	
	input_startPosX = $InputDevices.rect_global_position.x
	vBox_startPosX = $VBoxContainer.rect_global_position.x


func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("quit"):
		_on_Back_pressed()
		get_tree().set_input_as_handled()


func _notification(what):
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				#HACK: dont know why this fails in-game...
				if not (get_tree().current_scene is Spatial):
					# warning-ignore:return_value_discarded
					tween.interpolate_property($InputDevices, "rect_global_position:x", input_startPosX - 1920, input_startPosX, 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
					# warning-ignore:return_value_discarded
					tween.interpolate_property($VBoxContainer, "rect_global_position:x", vBox_startPosX + 1920, vBox_startPosX, 0.25, Tween.TRANS_CIRC, Tween.EASE_OUT)
					# warning-ignore:return_value_discarded
					tween.start()
				
				choicesParent.get_node("Music").grab_focus()


func _on_SettingsButton_pressed():
	visible = true
	set_process_input(true)
	emit_signal("settings_open")


func _on_Back_pressed():
	visible = false
	set_process_input(false)
	emit_signal("settings_close")
