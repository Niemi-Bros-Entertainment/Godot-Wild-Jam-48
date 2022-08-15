'Quit'
extends Node

var frameDelay :int = 60

# HACK: to allow quit sound to ring out before closing application
func _process(_delta):
	frameDelay -= 1
	if frameDelay <= 0:
		_quit()


func _quit():
	get_tree().quit()
