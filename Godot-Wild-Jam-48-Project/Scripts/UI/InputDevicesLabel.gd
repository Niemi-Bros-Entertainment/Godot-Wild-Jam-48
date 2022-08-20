'InputDevicesLabel'
extends Label

const FORMAT = "Input Devices:"


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	# warning-ignore:return_value_discarded
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	_update_display()
	

func _update_display():
	var joyIds = Input.get_connected_joypads()
	text = FORMAT
	for id in joyIds:
		text += "\n • (%s) %s" % [id, Input.get_joy_name(id)]
		#text += "\n • (%s) %s" % [id, Input.get_joy_name(id)]


func _on_joy_connection_changed(_device :int, _connected :bool):
	call_deferred("_update_display")
#	_update_display()
