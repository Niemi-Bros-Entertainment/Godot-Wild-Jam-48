'PlayerShip'
extends Spatial

export(float) var speed :float = 10.0
var speedMultiplier :float = 1.0
var alarmTimer :float = 0.0
var travelBonus :float = 0.0

onready var camera :Camera = $Camera
onready var defaultFov :float = camera.fov

onready var audio :AudioStreamPlayer3D= $AudioStreamPlayer3D
onready var light :OmniLight = $OmniLight
onready var tween :Tween = $Tween
onready var label :Label = $Label

const ALARM_DURATION = 1.5
const BOOST_SPEED_MULTIPLIER :float = 3.0
const BOOST_FOV :float = 60.0
const TRAVEL_POINT_MULTIPLIER :int = 10


func _ready():
	# warning-ignore:return_value_discarded
	GameManager.connect("game_over", self, "_on_game_over")
	
	label.percent_visible = 0.0
	
	# begin repeated flashing red light
	tween.repeat = true
	# warning-ignore:return_value_discarded
	tween.interpolate_property(light, "light_color", Color.red, Color.black, 0.5)
	# warning-ignore:return_value_discarded
	tween.start()
	
	# Stars use RemoteTransform node to follow position, rotation is ignored
	$Stars.set_as_toplevel(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event :InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("quit"):
			SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if event.is_action_pressed("quit"):
			SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
			_exit_game()
		elif event.is_action_pressed("l-click"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#	if event is InputEventMouseMotion:
#		match Input.get_mouse_mode():
#			Input.MOUSE_MODE_CAPTURED:
#				_adjust_look(event.relative * MOUSE_SENSITIVITY)


func _physics_process(delta):
	var input = get_input()
	speedMultiplier = move_toward(speedMultiplier, BOOST_SPEED_MULTIPLIER if Input.is_action_pressed("jetpack") else 1.0, delta)
	global_translate(speed * PhysicsUtility.get_gravity_dir(global_transform) * delta)
	rotate_x(-input.y * delta)
	rotate_y(-input.x * delta)
	
	camera.fov = lerp(defaultFov, BOOST_FOV, speedMultiplier-1)
	audio.pitch_scale = lerp(audio.pitch_scale, speedMultiplier + input.length(), delta)
	
	travelBonus += delta * (speedMultiplier * 2.0)
	while travelBonus > 5.0:
		travelBonus -= 5
		GameManager.add_points(100 * TRAVEL_POINT_MULTIPLIER)
	while travelBonus > 1.0:
		travelBonus -= 1
		GameManager.add_points(1 * TRAVEL_POINT_MULTIPLIER)

	
	_touchdown()
		
	if alarmTimer <= 0:
		alarmTimer = ALARM_DURATION
		SfxManager.enqueue2d(Enums.SoundType.ShipAlarm)
	else:
		alarmTimer -= delta
		
	if label.percent_visible < 1.0:
		label.percent_visible += delta
		SfxManager.enqueue2d(Enums.SoundType.Beep)
		
		
func _touchdown():
	if speedMultiplier > 1.5:
		if (Constants.ORIGIN - global_transform.origin).length() < Constants.MOON_RADIUS:
			SfxManager.enqueue2d(Enums.SoundType.Crash)
			GameManager.mission_over(Enums.AftermathType.Crashed)
			set_physics_process(false)
	else:
		if (Constants.ORIGIN - global_transform.origin).length() < Constants.MOON_RADIUS * 1.3:
			SfxManager.enqueue2d(Enums.SoundType.Ship2)
			GameManager.touchdown()
			set_physics_process(false)


# skip
func _input(event):
	if event.is_action_pressed("debug"):
		_touchdown()
		
		
func get_input() -> Vector3:
	var inputDir :Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		inputDir += -global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		inputDir += global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		inputDir += -global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		inputDir += global_transform.basis.x
	inputDir = inputDir.normalized()
	return inputDir


func _on_game_over():
	label.hide()


func _exit_game():
	set_physics_process(false)
	GameManager.abort()
