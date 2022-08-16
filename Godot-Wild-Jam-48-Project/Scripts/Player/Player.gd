'Player'
extends KinematicBody

onready var pivot :Spatial = $Pivot
onready var raycast :RayCast = $RayCast
onready var camera :Camera = $Pivot/Camera
onready var audio :AudioStreamPlayer3D = $AudioStreamPlayer3D

var mouseSensitivity :float= 0.002 # radians/pixel

const ORIGIN :Vector3 = Constants.ORIGIN
const MOON_RADIUS :float = Constants.MOON_RADIUS
const TRANSFORM_INTERPOLATE :float = 0.2
const LOOK_PITCH_LIMIT :float = deg2rad(89.0)
const GRAVITY_STRENGTH :float = 1.0
const JETPACK_STRENGTH :float = 0.75

export(float) var speed :float = 7.0
export(float) var acceleration :float = 5.0

var direction :Vector3 = Vector3.ZERO
var verticalVelocity :float = 0.0
var velocity :Vector3 = Vector3.ZERO

onready var up :Vector3 = global_transform.basis.y


func _ready():
	SfxManager.enqueue2d(Enums.SoundType.Ship1)
	
	raycast.cast_to = raycast.to_local(ORIGIN - raycast.global_transform.origin)
	raycast.force_raycast_update()
	if raycast.is_colliding(): 
		global_transform.origin = raycast.get_collision_point()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta :float):
	direction = get_input()
	up = -GameManager.get_gravity_dir(global_transform)
		
	raycast.cast_to = raycast.to_local(ORIGIN - raycast.global_transform.origin)
	#if raycast.is_colliding(): 
	#	transform.origin.y = raycast.get_collision_point().y
	
	if Input.is_action_pressed("jetpack"):
		verticalVelocity += JETPACK_STRENGTH * delta
	else:
		if not is_on_floor():
			verticalVelocity -= GRAVITY_STRENGTH * delta
		else:
			verticalVelocity = 0
	direction += up * verticalVelocity

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	#velocity = move_and_slide_with_snap(velocity, -up * GRAVITY_STRENGTH, up, true)
	velocity = move_and_slide(velocity, up, true)
	
	var xform :Transform = align_with_y(global_transform, up)
	global_transform = global_transform.interpolate_with(xform, TRANSFORM_INTERPOLATE)
	
	# if we somehow get too close to the origin, game over
	if raycast.cast_to.length_squared() < 1:
		_exit_game()


func align_with_y(xform :Transform, new_y :Vector3) -> Transform:
	return GameManager.align_with_y(xform, new_y)


func _unhandled_input(event :InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("ui_cancel"):
			SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if event.is_action_pressed("ui_cancel"):
			SfxManager.enqueue2d(Enums.SoundType.MenuCancel)
			_exit_game()
		elif event.is_action_pressed("l-click"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				SfxManager.enqueue2d(Enums.SoundType.MenuConfirm)
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				rotate(up, -event.relative.x * mouseSensitivity)
				pivot.rotate_x(-event.relative.y * mouseSensitivity)
				pivot.rotation.x = clamp(pivot.rotation.x, -LOOK_PITCH_LIMIT, LOOK_PITCH_LIMIT)


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


func _exit_game():
	set_physics_process(false)
	GameManager.abort()
