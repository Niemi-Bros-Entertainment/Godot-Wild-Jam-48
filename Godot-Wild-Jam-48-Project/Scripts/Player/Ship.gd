'Ship'
extends Spatial

export(float) var speed :float = 10.0
onready var audio :AudioStreamPlayer3D= $AudioStreamPlayer3D
onready var light = $OmniLight
onready var tween = $Tween


func _ready():
	tween.repeat = true
	tween.interpolate_property(light, "light_color", Color.red, Color.black, 0.5)
	tween.start()


func _physics_process(delta):
	var input = get_input()
	global_translate(speed * GameManager.get_gravity_dir(global_transform) * delta)
	rotate_x(-input.y * delta)
	rotate_y(-input.x * delta)
	
	audio.pitch_scale = lerp(audio.pitch_scale, 1.0 + input.length(), delta)
	
	if (Constants.ORIGIN - global_transform.origin).length() < Constants.MOON_RADIUS:
		#GameManager.abort() # TODO: determinging a successful touchdown
		_touchdown()
		
		
func _touchdown():
	SfxManager.enqueue2d(Enums.SoundType.Ship2)
	GameManager.touchdown()
	set_physics_process(false)
		
		
func _input(event):
	if event.is_action_pressed("ui_accept"):
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
