'GameManager'
extends Node



func engage():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.GAME_SCENE_PATH)


func abort():
	# warning-ignore:return_value_discarded
	get_tree().change_scene(Constants.TITLE_SCENE_PATH)
