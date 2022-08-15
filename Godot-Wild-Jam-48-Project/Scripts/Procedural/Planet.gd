# Sources:
# https://www.youtube.com/playlist?list=PL43PN07AM4J_7ZkZAUotpfijJSoibrvbr
# https://www.youtube.com/playlist?list=PLFt_AvWsXl0cONs3T0By4puYy6GM22ko8

'Procedural Moon/Planet'
tool
extends Moon

export(Resource) var planetData setget set_planet_data
var terrainFaces :Array = []
var collisionShapes :Array = []

const NORMALS :Array = [
	Vector3.UP,
	Vector3.DOWN,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.FORWARD,
	Vector3.BACK
]

func _ready():
	# only rotate if there's angular velocity to match
	#set_physics_process( not constant_angular_velocity.is_equal_approx( Vector3.ZERO ) )
	on_data_changed()
	
	
# base class
#func _physics_process(delta):
#	rotate_x(constant_angular_velocity.x * delta)
#	rotate_y(constant_angular_velocity.y * delta)
#	rotate_z(constant_angular_velocity.z * delta)
	
	
func on_data_changed():
	if is_instance_valid(planetData):
		planetData.reset()
		
	if terrainFaces.empty():
		terrainFaces.resize(NORMALS.size())
		collisionShapes.resize(NORMALS.size())
		for i in range(NORMALS.size()):
			var cs :CollisionShape = CollisionShape.new()
			var instance :TerrainFace = TerrainFace.new(NORMALS[i])
			terrainFaces[i] = instance
			collisionShapes[i] = cs
			add_child(instance)
			add_child(cs)
			instance.generate_mesh(planetData)
	else:
		for child in get_children():
			if child is TerrainFace:
				(child as TerrainFace).generate_mesh(planetData)
			
#	generate_mesh()
	for i in range(collisionShapes.size()):
		collisionShapes[i].shape = terrainFaces[i].convexShape


func generate_mesh():
	for t in terrainFaces:
		(t as TerrainFace).construct_mesh(planetData)


func set_planet_data(value):
	planetData = value
	on_data_changed()
	if planetData != null and not planetData.is_connected("changed", self, "on_data_changed"):
		planetData.connect("changed", self, "on_data_changed")
