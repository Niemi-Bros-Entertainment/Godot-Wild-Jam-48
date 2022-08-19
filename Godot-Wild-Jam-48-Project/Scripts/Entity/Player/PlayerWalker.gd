'PlayerWalker'
extends KinematicBody

onready var pivot :Spatial = $Pivot
onready var raycast :RayCast = $RayCast
onready var camera :Camera = $Pivot/Camera

onready var jetpackAudio :AudioStreamPlayer3D = $JetpackAudio
onready var ambianceAudio :AudioStreamPlayer3D = $AmbianceAudio

const MOUSE_SENSITIVITY :float = 0.002 # radians/pixel
const CONTROLLER_LOOK_SENSITIVITY :float= 0.05

const ORIGIN :Vector3 = Constants.ORIGIN
const MOON_RADIUS :float = Constants.MOON_RADIUS
const TRANSFORM_INTERPOLATE :float = 0.2
const LOOK_PITCH_LIMIT :float = deg2rad(89.0)
const GRAVITY_STRENGTH :float = 1.0
const JETPACK_STRENGTH :float = 1.0
const JETPACK_CAPACITY :float = 1.0
const MAX_VERTICAL_VELOCITY = 10.0

export(float) var speed :float = 7.0
export(float) var acceleration :float = 5.0

var direction :Vector3 = Vector3.ZERO
var verticalVelocity :float = 0.0
var velocity :Vector3 = Vector3.ZERO
var jetpack :float = JETPACK_CAPACITY

onready var up :Vector3 = global_transform.basis.y


func _ready():
	assert(has_node("Inventory"))
	# warning-ignore:return_value_discarded
	$Inventory.connect("inventory_changed", self, "_on_inventory_changed")
	SfxManager.enqueue2d(Enums.SoundType.Ship1)
	
	raycast.cast_to = raycast.to_local(ORIGIN - raycast.global_transform.origin)
	raycast.force_raycast_update()
	if raycast.is_colliding(): 
		global_transform.origin = raycast.get_collision_point()
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta :float):
	direction = get_move_input()
	up = -PhysicsUtility.get_gravity_dir(global_transform)
		
	raycast.cast_to = raycast.to_local(ORIGIN - raycast.global_transform.origin)
	#if raycast.is_colliding(): 
	#	transform.origin.y = raycast.get_collision_point().y
	
	var isJetpackOn :bool = Input.is_action_pressed("jetpack") and jetpack > 0
	if isJetpackOn:
		jetpack -= delta
		if not jetpackAudio.playing:
			jetpackAudio.play()
		verticalVelocity += JETPACK_STRENGTH * delta
		verticalVelocity = min(MAX_VERTICAL_VELOCITY, verticalVelocity)
	else:
		jetpack += delta
		if jetpackAudio.playing:
			jetpackAudio.stop()
		if not is_on_floor():
			verticalVelocity -= GRAVITY_STRENGTH * delta
			verticalVelocity = max(-MAX_VERTICAL_VELOCITY, verticalVelocity)
		else:
			if verticalVelocity < 0:
				if verticalVelocity < -0.5:
					SfxManager.enqueue(Enums.SoundType.Thud, global_transform.origin)
				verticalVelocity = 0
	direction += up * verticalVelocity

	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	#velocity = move_and_slide_with_snap(velocity, -up * GRAVITY_STRENGTH, up, true)
	velocity = move_and_slide(velocity, up, true)
	
	var xform :Transform = PhysicsUtility.align_with_y(global_transform, up)
	global_transform = global_transform.interpolate_with(xform, TRANSFORM_INTERPOLATE)
	
	jetpack = clamp(jetpack, -1.0, JETPACK_CAPACITY)
	$HUD.update_jetpack_01(jetpack / JETPACK_CAPACITY)
	
	_adjust_look( get_look_input() )
	
	# if we somehow get too close to the origin, game over
	if raycast.cast_to.length_squared() < 1:
		_exit_game()


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

	if event is InputEventMouseMotion:
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				_adjust_look(event.relative * MOUSE_SENSITIVITY)


func _adjust_look(v2 :Vector2):
	rotate(up, -v2.x)
	pivot.rotate_x(-v2.y)
	pivot.rotation.x = clamp(pivot.rotation.x, -LOOK_PITCH_LIMIT, LOOK_PITCH_LIMIT)


func get_move_input() -> Vector3:
	var inputDir :Vector3 = Vector3.ZERO
	inputDir += -global_transform.basis.z * Input.get_action_strength("move_forward")
	inputDir += global_transform.basis.z * Input.get_action_strength("move_backward")
	inputDir += -global_transform.basis.x * Input.get_action_strength("move_left")
	inputDir += global_transform.basis.x * Input.get_action_strength("move_right")
	inputDir = inputDir.limit_length()
	return inputDir


# used for controllers
func get_look_input() -> Vector2:
	var inputDir :Vector2 = Vector2.ZERO
	inputDir.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	inputDir.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	inputDir = inputDir.limit_length()
	return inputDir * CONTROLLER_LOOK_SENSITIVITY


func add_oxygen_depletion_multiplier(source, multiplier :float):
	$Oxygen.add_depletion_multiplier(source, multiplier)


func remove_oxygen_depletion_multiplier(source):
	$Oxygen.remove_depletion_multiplier(source)


func add_cheese(type :int):
	$Inventory.add_cheese(type)


func dump_cheese() -> bool:
	return $Inventory.dump_cheese()


func _on_inventory_changed():
	$HUD.update_cheese($Inventory.get_carried_cheese_count())


func is_full() -> bool:
	return $Inventory.is_full()


func get_vertical_speed() -> float:
	return verticalVelocity


func apply_force(dir :Vector3):
	verticalVelocity += dir.y


func _exit_game():
	set_physics_process(false)
	GameManager.abort()
