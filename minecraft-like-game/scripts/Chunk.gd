extends StaticBody3D

const CHUNK_SIZE = 16
const WORLD_HEIGHT = 64

var blocks = []
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready():
	mesh_instance = MeshInstance3D.new()
	collision_shape = CollisionShape3D.new()
	add_child(mesh_instance)
	add_child(collision_shape)

func set_blocks(block_data):
	blocks = block_data
	generate_mesh()

func generate_mesh():
	var array_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var colors = PackedColorArray()
	var indices = PackedInt32Array()
	
	var vertex_count = 0
	
	for x in range(CHUNK_SIZE):
		for y in range(WORLD_HEIGHT):
			for z in range(CHUNK_SIZE):
				var block_type = blocks[x][y][z]
				if block_type == BlockTypes.AIR:
					continue
				
				var block_pos = Vector3(x, y, z)
				var block_color = BlockTypes.get_block_color(block_type)
				
				# Check each face
				var faces = [
					# Front face (positive Z)
					{ "normal": Vector3(0, 0, 1), "check": Vector3(0, 0, 1) },
					# Back face (negative Z)
					{ "normal": Vector3(0, 0, -1), "check": Vector3(0, 0, -1) },
					# Right face (positive X)
					{ "normal": Vector3(1, 0, 0), "check": Vector3(1, 0, 0) },
					# Left face (negative X)
					{ "normal": Vector3(-1, 0, 0), "check": Vector3(-1, 0, 0) },
					# Top face (positive Y)
					{ "normal": Vector3(0, 1, 0), "check": Vector3(0, 1, 0) },
					# Bottom face (negative Y)
					{ "normal": Vector3(0, -1, 0), "check": Vector3(0, -1, 0) }
				]
				
				for face in faces:
					var check_pos = block_pos + face.check
					if should_render_face(check_pos):
						add_face(vertices, normals, colors, indices, block_pos, face.normal, block_color, vertex_count)
						vertex_count += 4
	
	if vertices.size() > 0:
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_INDEX] = indices
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh_instance.mesh = array_mesh
		
		# Generate collision
		collision_shape.shape = array_mesh.create_trimesh_shape()

func should_render_face(pos: Vector3) -> bool:
	if pos.x < 0 or pos.x >= CHUNK_SIZE or pos.y < 0 or pos.y >= WORLD_HEIGHT or pos.z < 0 or pos.z >= CHUNK_SIZE:
		return true
	return blocks[int(pos.x)][int(pos.y)][int(pos.z)] == BlockTypes.AIR

func add_face(vertices: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray, indices: PackedInt32Array, pos: Vector3, normal: Vector3, color: Color, vertex_count: int):
	var face_vertices = get_face_vertices(pos, normal)
	
	for vertex in face_vertices:
		vertices.append(vertex)
		normals.append(normal)
		colors.append(color)
	
	# Add triangle indices
	indices.append(vertex_count)
	indices.append(vertex_count + 1)
	indices.append(vertex_count + 2)
	indices.append(vertex_count)
	indices.append(vertex_count + 2)
	indices.append(vertex_count + 3)

func get_face_vertices(pos: Vector3, normal: Vector3) -> Array:
	var vertices = []
	
	if normal == Vector3(0, 0, 1):  # Front
		vertices = [
			pos + Vector3(0, 0, 1),
			pos + Vector3(1, 0, 1),
			pos + Vector3(1, 1, 1),
			pos + Vector3(0, 1, 1)
		]
	elif normal == Vector3(0, 0, -1):  # Back
		vertices = [
			pos + Vector3(1, 0, 0),
			pos + Vector3(0, 0, 0),
			pos + Vector3(0, 1, 0),
			pos + Vector3(1, 1, 0)
		]
	elif normal == Vector3(1, 0, 0):  # Right
		vertices = [
			pos + Vector3(1, 0, 1),
			pos + Vector3(1, 0, 0),
			pos + Vector3(1, 1, 0),
			pos + Vector3(1, 1, 1)
		]
	elif normal == Vector3(-1, 0, 0):  # Left
		vertices = [
			pos + Vector3(0, 0, 0),
			pos + Vector3(0, 0, 1),
			pos + Vector3(0, 1, 1),
			pos + Vector3(0, 1, 0)
		]
	elif normal == Vector3(0, 1, 0):  # Top
		vertices = [
			pos + Vector3(0, 1, 1),
			pos + Vector3(1, 1, 1),
			pos + Vector3(1, 1, 0),
			pos + Vector3(0, 1, 0)
		]
	elif normal == Vector3(0, -1, 0):  # Bottom
		vertices = [
			pos + Vector3(0, 0, 0),
			pos + Vector3(1, 0, 0),
			pos + Vector3(1, 0, 1),
			pos + Vector3(0, 0, 1)
		]
	
	return vertices

func destroy_block(world_pos: Vector3):
	var local_pos = world_pos - global_position
	var x = int(local_pos.x)
	var y = int(local_pos.y)
	var z = int(local_pos.z)
	
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < WORLD_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		blocks[x][y][z] = BlockTypes.AIR
		generate_mesh()

func place_block(world_pos: Vector3, block_type):
	var local_pos = world_pos - global_position
	var x = int(local_pos.x)
	var y = int(local_pos.y)
	var z = int(local_pos.z)
	
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < WORLD_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		blocks[x][y][z] = block_type
		generate_mesh()
