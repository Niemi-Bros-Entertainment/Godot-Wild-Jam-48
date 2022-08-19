class_name PhysicsUtility extends Reference

const ORIGIN = Constants.ORIGIN


static func get_gravity_dir(globalTransform :Transform) -> Vector3:
	return (ORIGIN - globalTransform.origin).normalized()


static func align_with_y(xform :Transform, new_y :Vector3) -> Transform:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
