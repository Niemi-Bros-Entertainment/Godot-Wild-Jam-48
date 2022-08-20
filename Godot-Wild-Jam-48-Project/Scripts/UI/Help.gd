'Help'
extends Control

onready var labels :Array = get_node("HBoxContainer").get_children()
var _speed :float = BASE_SPEED
const BASE_SPEED = 0.5


func _ready():
	for label in labels:
		label.percent_visible = 0


func _input(event):
	for label in labels:
		if label.percent_visible < 1.0:
			return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("l-click"):
		SceneManager.go_to(Constants.TITLE_SCENE_PATH)
	

func _process(delta):
	var shouldBeep = false
	
	_speed = 2.0 if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("l-click") else BASE_SPEED
	for label in labels:
		if label.percent_visible < 1.0:
			shouldBeep = true
			label.percent_visible += delta * _speed
	
	if shouldBeep:
		SfxManager.enqueue2d(Enums.SoundType.Beep)
