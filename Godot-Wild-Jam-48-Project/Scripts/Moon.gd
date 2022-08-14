extends StaticBody


func _ready():
	# we want the child Directional Light to maintain its transform, use global
	$DirectionalLight.set_as_toplevel(true)


func _physics_process(delta):
	rotate_x(constant_angular_velocity.x * delta)
	rotate_y(constant_angular_velocity.y * delta)
	rotate_z(constant_angular_velocity.z * delta)
