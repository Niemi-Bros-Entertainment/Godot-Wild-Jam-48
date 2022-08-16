tool
class_name Moon extends StaticBody


func _ready():
	# only rotate if there's angular velocity and not in the editor
	set_physics_process( not constant_angular_velocity.is_equal_approx( Vector3.ZERO ) and not Engine.editor_hint )


func _physics_process(delta):
	rotate_x(constant_angular_velocity.x * delta)
	rotate_y(constant_angular_velocity.y * delta)
	rotate_z(constant_angular_velocity.z * delta)


func get_point_on_planet(pointOnSphere :Vector3) -> Vector3:
	return pointOnSphere
