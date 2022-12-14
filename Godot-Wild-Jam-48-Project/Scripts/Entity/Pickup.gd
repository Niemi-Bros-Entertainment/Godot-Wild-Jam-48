'Pickup'
extends Area

const CheeseType = Enums.CheeseType
const PICKUP_PARTICLE_PREFAB = Constants.PICKUP_PARTICLE_PREFAB

export(CheeseType) var cheeseType :int = CheeseType.Swiss
export(Vector3) var rotateVector :Vector3 = Vector3(0.0, 1.0, 0.0)
onready var tween :Tween = $Tween

const ORIGIN :Vector3 = Constants.ORIGIN


#func _notification(what):
#	match what:
#		NOTIFICATION_VISIBILITY_CHANGED:
#			if not is_visible_in_tree():
#				_check_victory()


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	
	# align pickup to surface
	var xform :Transform = PhysicsUtility.align_with_y(global_transform, -PhysicsUtility.get_gravity_dir(global_transform))
	global_transform = xform
	
	# start the perpetual pickup spin
	assert(tween)
	tween.repeat = true
	tween.playback_process_mode = Tween.TWEEN_PROCESS_PHYSICS
	# warning-ignore:return_value_discarded
	tween.interpolate_property($MeshInstance, "rotation_degrees", $MeshInstance.rotation_degrees, rotateVector * 360, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# warning-ignore:return_value_discarded
	tween.start()


func _on_body_entered(_body):
	if _body.is_in_group("Player") and not _body.is_full():
		collect(_body)


func collect(body):
	var particle = PICKUP_PARTICLE_PREFAB.instance()
	particle.transform.origin = transform.origin
	get_parent().add_child(particle)
	remove_from_group("Pickup")
	hide() # triggers victory check
	queue_free()
	GameManager.add_points(Constants.CHEESE_POINT_LOOKUP.get(cheeseType, 1), true)
	SfxManager.enqueue(Enums.SoundType.Pickup, global_transform.origin)
	body.add_cheese(cheeseType)


#func _check_victory():
#	if get_tree().get_nodes_in_group("Pickup").size() <= 0:
#		GameManager.mission_over(Enums.AftermathType.Success)
