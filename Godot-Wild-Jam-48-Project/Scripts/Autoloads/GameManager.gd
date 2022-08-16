'GameManager'
'GameManager'
extends Node

const POST_PROCESS_PREFAB = preload("res://Scenes/Prefabs/VFX/PostProcess.tscn")
const AMBIANCE_AUDIO_PREFAB = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
const ORIGIN :Vector3 = Constants.ORIGIN

var _ambiance :AudioStreamPlayer
var _postProcess :Control


func _ready():
	_postProcess = POST_PROCESS_PREFAB.instance()
	add_child(_postProcess)
	_ambiance = AMBIANCE_AUDIO_PREFAB.instance()
	add_child(_ambiance)
	
	Engine.target_fps = 60


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
