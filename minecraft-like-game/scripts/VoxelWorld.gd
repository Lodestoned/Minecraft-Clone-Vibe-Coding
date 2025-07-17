extends Node3D

const CHUNK_SIZE = 16
const WORLD_HEIGHT = 64
const RENDER_DISTANCE = 4

var chunks = {}
var chunk_scene = preload("res://scenes/Chunk.tscn")
var noise: FastNoiseLite

func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func initialize_world():
	# Generate initial chunks around origin
	for x in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
		for z in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
			generate_chunk(Vector2i(x, z))

func generate_chunk(chunk_pos: Vector2i):
	if chunk_pos in chunks:
		return
	
	var chunk = chunk_scene.instantiate()
	chunk.position = Vector3(chunk_pos.x * CHUNK_SIZE, 0, chunk_pos.y * CHUNK_SIZE)
	add_child(chunk)
	
	# Generate terrain data
	var blocks = []
	for x in range(CHUNK_SIZE):
		blocks.append([])
		for y in range(WORLD_HEIGHT):
			blocks[x].append([])
			for z in range(CHUNK_SIZE):
				var world_x = chunk_pos.x * CHUNK_SIZE + x
				var world_z = chunk_pos.y * CHUNK_SIZE + z
				var height = int(noise.get_noise_2d(world_x, world_z) * 20 + 30)
				
				var block_type = BlockTypes.AIR
				if y < height - 3:
					block_type = BlockTypes.STONE
				elif y < height - 1:
					block_type = BlockTypes.DIRT
				elif y < height:
					block_type = BlockTypes.GRASS
				
				blocks[x][y].append(block_type)
	
	chunk.set_blocks(blocks)
	chunks[chunk_pos] = chunk

func get_chunk_at_position(pos: Vector3) -> Node3D:
	var chunk_pos = Vector2i(int(pos.x / CHUNK_SIZE), int(pos.z / CHUNK_SIZE))
	if chunk_pos in chunks:
		return chunks[chunk_pos]
	return null
