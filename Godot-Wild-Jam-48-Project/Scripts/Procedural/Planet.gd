'Planet'
tool
extends Spatial

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
	on_data_changed()
	
	
func on_data_changed():
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
	generate_mesh()
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
