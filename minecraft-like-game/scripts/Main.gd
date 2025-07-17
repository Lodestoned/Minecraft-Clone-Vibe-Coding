extends Node3D

@onready var player = $Player
@onready var voxel_world = $VoxelWorld

func _ready():
	# Initialize the world
	voxel_world.initialize_world()
	
	# Position player above the world
	player.position = Vector3(0, 50, 0)
