'UIFadeOut'
extends Control

export(float) var multiplier :float = 2.0

signal faded_out
signal faded_in


func _ready():
	_reset()


func _process(delta :float):
	modulate.a -= delta * multiplier
	if multiplier > 0:
		if modulate.a <= 0:
			visible = false
			emit_signal("faded_out")
			set_process(false)
	else:
		if modulate.a >= 1:
			emit_signal("faded_in")
			set_process(false)


func _reset():
	modulate.a = 1.0 if multiplier > 0.0 else 0.01
	visible = modulate.a > 0


func pause():
	set_process(false)
	visible = false
	
	
func resume():
	_reset()
	set_process(true)
