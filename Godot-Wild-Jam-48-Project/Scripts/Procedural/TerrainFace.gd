class_name TerrainFace extends MeshInstance

export(Vector3) var normal :Vector3 = Vector3.ZERO

var proceduralMesh :ArrayMesh
var convexShape :Shape
var axisA :Vector3 
var axisB :Vector3


func _init(_n :Vector3):
	normal = _n
	axisA = Vector3(normal.y, normal.z, normal.x)
	axisB = normal.cross(axisA)
	proceduralMesh = ArrayMesh.new()
	name = str(_n)
	
	
func construct_mesh(data :PlanetData):
	var arrays :Array = [] # Array of mesh arrays
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertexArray = PoolVector3Array()
	var uvArray = PoolVector3Array()
	var normalArray = PoolVector3Array()
	var indexArray = PoolIntArray()
	
	var resolution :int = data.resolution
	
	var numVertices = resolution * resolution
	var numTriangles = (resolution-1) * (resolution-1) * 6
	
	normalArray.resize(numVertices)
	uvArray.resize(numVertices)
	vertexArray.resize(numVertices)
	indexArray.resize(numTriangles)
	
	var triIndex :int = 0
	for y in range(resolution):
		for x in range(resolution):
			var i = x + y * resolution
			var percent = Vector2(x, y) / (resolution - 1)
			var pointOnUnitCube :Vector3 = normal + (percent.x - 0.5) * 2 * axisA + (percent.y - 0.5) * 2 * axisB
			var pointOnUnitSphere :Vector3 = pointOnUnitCube.normalized()
			var pointOnPlanet = data.point_on_planet(pointOnUnitSphere)
			#vertexArray[i] = pointOnUnitSphere * data.radius
			vertexArray[i] = pointOnPlanet
			
			if x != resolution-1 and y != resolution-1:
				indexArray[triIndex + 2] = i
				indexArray[triIndex + 1] = i+resolution+1
				indexArray[triIndex] = i+resolution
				
				indexArray[triIndex + 5] = i
				indexArray[triIndex + 4] = i+1
				indexArray[triIndex + 3] = i+resolution+1
				triIndex += 6
				
	for a in range(0, indexArray.size(), 3):
		var b :int = a + 1
		var c :int = a + 2
		var ab :Vector3 = vertexArray[indexArray[b]] - vertexArray[indexArray[a]]
		var bc :Vector3 = vertexArray[indexArray[c]] - vertexArray[indexArray[b]]
		var ca :Vector3 = vertexArray[indexArray[a]] - vertexArray[indexArray[c]]
		var cross_ab_bc :Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca :Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab :Vector3 = ab.cross(ab) * -1.0
		normalArray[indexArray[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normalArray[indexArray[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normalArray[indexArray[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
	
	for i in range(normalArray.size()):
		normalArray[i] = normalArray[i].normalized()
		
	arrays[Mesh.ARRAY_VERTEX] = vertexArray
	arrays[Mesh.ARRAY_NORMAL] = normalArray
	arrays[Mesh.ARRAY_TEX_UV] = uvArray
	arrays[Mesh.ARRAY_INDEX] = indexArray
	
	call_deferred("_update_mesh", arrays)


func _update_mesh(arrays :Array):
	proceduralMesh.clear_surfaces()
	proceduralMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = proceduralMesh
	convexShape = mesh.create_trimesh_shape()


#func construct_mesh():
#	var verts = PoolVector3Array()
#	verts.resize(resolution * resolution)
#	var triangles = Array()
#	triangles.resize((resolution-1) * (resolution-1) * 6)
#	var triIndex :int = 0
#
#	for y in range(resolution):
#		for x in range(resolution):
#			var i = x + y * resolution
#			var percent = Vector2(x, y) / (resolution - 1)
#			var pointOnUnitCube = normal + (percent.x - 0.5) * 2 * axisA + (percent.y - 0.5) * 2 * axisB
#			verts[i] = pointOnUnitCube
#
#			if x != resolution-1 and y != resolution-1:
#				triangles[triIndex] = i
#				triangles[triIndex + 1] = i+resolution+1
#				triangles[triIndex + 2] = i+resolution
#
#				triangles[triIndex + 3] = i
#				triangles[triIndex + 4] = i+1
#				triangles[triIndex + 5] = i+resolution+1
#				triIndex += 6
#
#	proceduralMesh.clear_surfaces()
#	var resultArrays :Array = []
#	resultArrays.resize(ArrayMesh.ARRAY_MAX)
#	resultArrays[ArrayMesh.ARRAY_VERTEX] = verts
#	proceduralMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, resultArrays)
#	mesh = proceduralMesh
#
