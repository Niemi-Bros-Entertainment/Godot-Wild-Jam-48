tool
class_name Moon extends StaticBody


func _ready():
	# only rotate if there's angular velocity to match
	set_physics_process( not constant_angular_velocity.is_equal_approx( Vector3.ZERO ) )


func _physics_process(delta):
	rotate_x(constant_angular_velocity.x * delta)
	rotate_y(constant_angular_velocity.y * delta)
	rotate_z(constant_angular_velocity.z * delta)
