'GameManager'
extends Node

signal game_over
signal cheese_goal_reached
signal score_changed

const POST_PROCESS_PREFAB = preload("res://Scenes/Prefabs/UI/PostProcess.tscn")
const AMBIANCE_AUDIO_PREFAB = preload("res://Scenes/Prefabs/Audio/Ambiance.tscn")
const AFTERMATH_HUD_PREFAB = preload("res://Scenes/Prefabs/UI/HUDAftermath.tscn")

const ORIGIN :Vector3 = Constants.ORIGIN

onready var defaultResolution :Vector2 = OS.get_screen_size()
var _ambiance :AudioStreamPlayer
var _postProcess :Control
var _startTicks :int = 0
var _score :int = 0
var _cheesiness :int = 0


func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _ready():
	_postProcess = POST_PROCESS_PREFAB.instance()
	add_child(_postProcess)
	_ambiance = AMBIANCE_AUDIO_PREFAB.instance()
	add_child(_ambiance)
	
	# Wait for window resize event before changing resolution upon going full screen or
	# resolution update won't work as expected with a single button press
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "on_window_resize")
	on_window_resize()
	
	Engine.target_fps = 60


func on_window_resize():
	if defaultResolution == Vector2.ZERO:
		return
		
#	if not OS.window_fullscreen:
	#OS.window_size = defaultResolution
	get_viewport().set_size(defaultResolution)
	center_window()


func center_window():
	# re-center window after resize
	var screen_size :Vector2 = OS.get_screen_size()
	var window_size :Vector2 = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func engage():
	_startTicks = OS.get_unix_time()
	_postProcess.material.set_shader_param("vignette_intensity", 1.0)
	_postProcess.material.set_shader_param("vignette_rgb", Color(0.05, 0, 0))
#	call_deferred("_swap_scene", Constants.BRIEFING_SCENE_PATH)
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


func mission_over(type :int = Enums.AftermathType.InsufficientCheese):
	emit_signal("game_over")
	match type:
		Enums.AftermathType.Success:
			add_points(Constants.SUCCESS_BONUS_POINTS)
			SfxManager.enqueue2d(Enums.SoundType.MissionSuccess)
		_:
			SfxManager.enqueue2d(Enums.SoundType.MissionFail)
			
	var aftermath = AFTERMATH_HUD_PREFAB.instance()
	aftermath.update_display(type)
	get_tree().current_scene.add_child(aftermath)


func quit_game():
	call_deferred("_swap_scene", Constants.QUIT_SCENE_PATH)


func _input(event):
	if event.is_action_pressed("vision"):
		SfxManager.enqueue2d(Enums.SoundType.VisionToggle)
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_OVERDRAW if get_viewport().debug_draw != Viewport.DEBUG_DRAW_OVERDRAW else Viewport.DEBUG_DRAW_DISABLED


func _swap_scene(targetScenePath :String):
	# warning-ignore:return_value_discarded
#	get_tree().change_scene(targetScenePath)
	SceneManager.go_to(targetScenePath)


# --- SCORE ---

func add_points(p :int, isCheese :bool = false):
	if isCheese:
		var hasReachedGoal :bool = _cheesiness >= Constants.CHEESE_GOAL
		_cheesiness += p
		if not hasReachedGoal and _cheesiness >= Constants.CHEESE_GOAL:
			emit_signal("cheese_goal_reached")
	_score += p
	emit_signal("score_changed")


func clear_score():
	_score = 0
	_cheesiness = 0
	emit_signal("score_changed")


func get_session_start_tick() -> int:
	return _startTicks


func get_score() -> int:
	return _score
	

func get_cheese_score() -> int:
	return _cheesiness
