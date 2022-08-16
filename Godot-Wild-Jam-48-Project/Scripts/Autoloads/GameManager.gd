'GameManager'
extends Node

const AMBIANCE_AUDIO = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
const ORIGIN :Vector3 = Constants.ORIGIN

var _ambiance :AudioStreamPlayer


func _ready():
	_ambiance = AMBIANCE_AUDIO.instance()
	add_child(_ambiance)


func engage():
	call_deferred("_swap_scene", Constants.TOUCHDOWN_SCENE_PATH)


func touchdown():
	call_deferred("_swap_scene", Constants.GAME_SCENE_PATH)


func abort():
	call_deferred("_swap_scene", Constants.TITLE_SCENE_PATH)


func quit_game():
	call_deferred("_swap_scene", Constants.QUIT_SCENE_PATH)


func _swap_scene(targetScenePath :String):
	# warning-ignore:return_value_discarded
#	get_tree().change_scene(targetScenePath)
	SceneManager.go_to(targetScenePath)


func get_gravity_dir(globalTransform :Transform) -> Vector3:
	return (ORIGIN - globalTransform.origin).normalized()


func align_with_y(xform :Transform, new_y :Vector3) -> Transform:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
