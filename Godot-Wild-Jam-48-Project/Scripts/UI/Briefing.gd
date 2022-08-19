'Briefing'
extends Control

onready var label :Label = $Label
var _speed :float = BASE_SPEED
const BASE_SPEED = 0.5


func _ready():
	label.percent_visible = 0


func _input(event):
	if label.percent_visible < 1.0:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("l-click"):
		SceneManager.go_to(Constants.TOUCHDOWN_SCENE_PATH)
	

func _process(delta):
	_speed = 2.0 if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("l-click") else BASE_SPEED
	if label.percent_visible < 1.0:
		label.percent_visible += delta * _speed
		SfxManager.enqueue2d(Enums.SoundType.Beep)
