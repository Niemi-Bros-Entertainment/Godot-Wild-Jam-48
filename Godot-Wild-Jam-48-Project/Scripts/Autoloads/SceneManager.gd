'SceneManager'
extends CanvasLayer

enum {
	FREE,
	LOADING
}

var _state :int = 0
var _loadTimer :float = 0
var _targetScenePath :String

var _fader

const EMPTY_STRING = ""
const FADE_OUT_DURATION = 0.5
const FADE_OUT_PREFAB = preload("res://Scenes/Prefabs/UI/FadeOut.tscn")


func _ready():
	layer = 128
	pause_mode = Node.PAUSE_MODE_PROCESS
	_fader = FADE_OUT_PREFAB.instance()
	_fader.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(_fader)
	_fader.pause()


func is_loading() -> bool:
	return _state == LOADING


func go_to(path :String):
	if path == _targetScenePath:
		return
	#ParticleManager.set_active(false)
	
	assert(ResourceLoader.exists(path))
	_targetScenePath = path
	_loadTimer = 0
	_state = LOADING
	_fader.resume()
	# warning-ignore:return_value_discarded
#	if get_tree().change_scene(path) != OK:
#		push_error("Failed to open scene at %s" % path)


func _swap_scene():
	if get_tree().change_scene(_targetScenePath) != OK:
		push_error("Failed to open scene at %s" % _targetScenePath)
	_state = FREE
	_fader.pause()
	_targetScenePath = EMPTY_STRING


func _physics_process(delta :float):
	match _state:
		FREE:
			return
		LOADING:
			if _loadTimer >= FADE_OUT_DURATION:
				_swap_scene()
			_loadTimer += delta
