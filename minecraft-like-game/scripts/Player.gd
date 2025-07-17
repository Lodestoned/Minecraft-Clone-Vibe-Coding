extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 8.0
@export var mouse_sensitivity = 0.002
@export var reach_distance = 5.0

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var voxel_world = get_parent().get_node("VoxelWorld")

var gravity = 20.0
var current_block_type = BlockTypes.STONE

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast.target_position = Vector3(0, 0, -reach_distance)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			handle_block_interaction()
	
	if event.is_action_pressed("right_click"):
		place_block()
	
	# Block selection
	if event.is_action_pressed("block_1"):
		current_block_type = BlockTypes.STONE
	elif event.is_action_pressed("block_2"):
		current_block_type = BlockTypes.DIRT
	elif event.is_action_pressed("block_3"):
		current_block_type = BlockTypes.GRASS

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func handle_block_interaction():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_method("destroy_block"):
			var hit_point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			var block_pos = (hit_point - normal * 0.1).floor()
			collider.destroy_block(block_pos)

func place_block():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_method("place_block"):
			var hit_point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			var block_pos = (hit_point + normal * 0.1).floor()
			collider.place_block(block_pos, current_block_type)
