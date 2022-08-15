'GameManager'
extends Node

const AMBIANCE_AUDIO = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
var _ambiance :AudioStreamPlayer


func _ready():
	_ambiance = AMBIANCE_AUDIO.instance()
	add_child(_ambiance)


func engage():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.GAME_SCENE_PATH)


func abort():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.TITLE_SCENE_PATH)


func quit_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.QUIT_SCENE_PATH)
