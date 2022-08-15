'GameManager'
extends Node

const AMBIANCE_AUDIO = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
var _ambiance :AudioStreamPlayer


func _ready():
	_ambiance = AMBIANCE_AUDIO.instance()
	add_child(_ambiance)


func engage():
	call_deferred("_swap_scene", Constants.GAME_SCENE_PATH)


func abort():
	call_deferred("_swap_scene", Constants.TITLE_SCENE_PATH)


func quit_game():
	call_deferred("_swap_scene", Constants.QUIT_SCENE_PATH)


func _swap_scene(targetScenePath :String):
	# warning-ignore:return_value_discarded
#	get_tree().change_scene(targetScenePath)
	SceneManager.go_to(targetScenePath)
