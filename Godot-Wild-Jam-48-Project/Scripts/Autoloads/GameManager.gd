'GameManager'
extends Node

signal game_over
signal score_changed

const POST_PROCESS_PREFAB = preload("res://Scenes/Prefabs/UI/PostProcess.tscn")
const AMBIANCE_AUDIO_PREFAB = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
const AFTERMATH_HUD_PREFAB = preload("res://Scenes/Prefabs/UI/HUDAftermath.tscn")

const ORIGIN :Vector3 = Constants.ORIGIN

var _ambiance :AudioStreamPlayer
var _postProcess :Control
var _score :int = 0


func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _ready():
	_postProcess = POST_PROCESS_PREFAB.instance()
	add_child(_postProcess)
	_ambiance = AMBIANCE_AUDIO_PREFAB.instance()
	add_child(_ambiance)
	
	Engine.target_fps = 60


func engage():
	_postProcess.material.set_shader_param("vignette_intensity", 1.0)
	_postProcess.material.set_shader_param("vignette_rgb", Color(0.05, 0, 0))
	call_deferred("_swap_scene", Constants.TOUCHDOWN_SCENE_PATH)


func touchdown():
	_postProcess.material.set_shader_param("vignette_intensity", 1.0)
	_postProcess.material.set_shader_param("vignette_rgb", Color(0.05, 0.05, 0))
	call_deferred("_swap_scene", Constants.GAME_SCENE_PATH)


func abort():
	_postProcess.material.set_shader_param("vignette_intensity", 0.4)
	_postProcess.material.set_shader_param("vignette_rgb", Color.black)
	call_deferred("_swap_scene", Constants.TITLE_SCENE_PATH)
	clear_score()


func mission_fail(type :int = Enums.AftermathType.InsufficientCheese):
	emit_signal("game_over")
	SfxManager.enqueue2d(Enums.SoundType.MissionFail)
	var aftermath = AFTERMATH_HUD_PREFAB.instance()
	aftermath.update_display(type)
	get_tree().current_scene.add_child(aftermath)


func mission_success():
	emit_signal("game_over")
	add_points(Constants.SUCCESS_BONUS_POINTS)
	SfxManager.enqueue2d(Enums.SoundType.MissionSuccess)
	var aftermath = AFTERMATH_HUD_PREFAB.instance()
	aftermath.update_display(Enums.AftermathType.Success)
	get_tree().current_scene.add_child(aftermath)


func quit_game():
	call_deferred("_swap_scene", Constants.QUIT_SCENE_PATH)


func _input(event):
	if event.is_action_pressed("vision"):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW if get_viewport().debug_draw != Viewport.DEBUG_DRAW_OVERDRAW else Viewport.DEBUG_DRAW_DISABLED


func _swap_scene(targetScenePath :String):
	# warning-ignore:return_value_discarded
#	get_tree().change_scene(targetScenePath)
	SceneManager.go_to(targetScenePath)


# --- SCORE ---

func add_points(p :int):
	_score += p
	emit_signal("score_changed")


func clear_score():
	_score = 0
	emit_signal("score_changed")


func get_score() -> int:
	return _score
	
