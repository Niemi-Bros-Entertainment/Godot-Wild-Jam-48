class_name Speed extends Node

var _speedMultiplier :float = DEFAULT_SPEED

const DEFAULT_SPEED :float = 1.0
const INTERPOLATE_SPEED :float = 1.0


func set_speed_multiplier(multiplier :float):
	_speedMultiplier = multiplier


func get_speed_multiplier() -> float:
	return _speedMultiplier
	
	
func _physics_process(delta):
	_speedMultiplier = move_toward(_speedMultiplier, DEFAULT_SPEED, delta * INTERPOLATE_SPEED)
