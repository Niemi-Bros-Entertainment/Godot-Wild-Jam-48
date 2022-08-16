extends Spatial

onready var tween :Tween = $Tween
export(Vector3) var rotateVector :Vector3 = Vector3.RIGHT
export(float) var duration :float = 5.0 # duration for a full revolution


func _ready():
	# start the perpetual pickup spin
	assert(tween)
	tween.repeat = true
	tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
	# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "rotation_degrees", self.rotation_degrees, rotateVector * 360, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	tween.start()
