extends KinematicBody

onready var pivot :Spatial = $Pivot
onready var raycast :RayCast = $RayCast
onready var camera :Camera = $Pivot/Camera

var mouseSensitivity = 0.002 # radians/pixel

const ORIGIN :Vector3 = Vector3.ZERO
const MOON_RADIUS :float = Constants.MOON_RADIUS
const TRANSFORM_INTERPOLATE :float = 0.2
const LOOK_PITCH_LIMIT :float = deg2rad(89.0)
const GRAVITY_STRENGTH :float = 10.0

export(float) var speed = 8.0
export(float) var acceleration = 5.0

var direction :Vector3 = Vector3.ZERO
var velocity :Vector3 = Vector3.ZERO

onready var up :Vector3 = global_transform.basis.y


func _ready():
	#global_transform.origin.y = MOON_RADIUS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta :float):
	direction = get_input()
	up = -get_gravity_dir()
		
	raycast.cast_to = raycast.to_local(ORIGIN - raycast.global_transform.origin)
	#if raycast.is_colliding(): 
	#	transform.origin.y = raycast.get_collision_point().y
	
	if not is_on_floor():
		direction += -up * GRAVITY_STRENGTH

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide_with_snap(velocity, -up * GRAVITY_STRENGTH, up, true)
	#velocity = move_and_slide(velocity, up, true)
	
	var xform :Transform = align_with_y(global_transform, up)
	global_transform = global_transform.interpolate_with(xform, TRANSFORM_INTERPOLATE)


func align_with_y(xform :Transform, new_y :Vector3) -> Transform:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
#
#
func _unhandled_input(event :InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if event.is_action_pressed("ui_cancel"):
			_exit_game()
		elif event.is_action_pressed("l-click"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				rotate(up, -event.relative.x * mouseSensitivity)
				pivot.rotate_x(-event.relative.y * mouseSensitivity)
				pivot.rotation.x = clamp(pivot.rotation.x, -LOOK_PITCH_LIMIT, LOOK_PITCH_LIMIT)


func get_gravity_dir() -> Vector3:
	return (ORIGIN - global_transform.origin).normalized()


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
	GameManager.abort()
