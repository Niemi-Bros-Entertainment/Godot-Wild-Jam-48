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
	regenerate_mesh()
	
	
func on_data_changed():
#	print("Data Changed!")
#	print_stack()

	if is_instance_valid(planetData):
		planetData.reset()
		
	if terrainFaces.empty():
		terrainFaces.resize(NORMALS.size())
		for i in range(NORMALS.size()):
			var instance :PlanetFace = PlanetFace.new(NORMALS[i])
			terrainFaces[i] = instance
			add_child(instance)
			instance.generate_mesh(planetData)
	else:
		for child in terrainFaces:
			(child as PlanetFace).generate_mesh(planetData)
			
	if collisionShapes.empty():
		collisionShapes.resize(NORMALS.size())
		for i in range(NORMALS.size()):
			var cs :CollisionShape = CollisionShape.new()
			collisionShapes[i] = cs
			add_child(cs)
	else:
		for cs in collisionShapes:
			cs.shape = null
			
	# update collision shapes
	for i in range(collisionShapes.size()):
		collisionShapes[i].shape = terrainFaces[i].convexShape
		
#	print("Finished updating procedural planet")


func regenerate_mesh():
	# randomize seed, causes issues...
#	randomize()
#	if is_instance_valid(planetData):
#		planetData.update_seed(randi())
	
	on_data_changed()


func set_planet_data(value):
	planetData = value
	on_data_changed()
	if planetData != null and not planetData.is_connected("changed", self, "on_data_changed"):
		planetData.connect("changed", self, "on_data_changed")
