extends Resource
class_name BlockTypes

enum Type {
	AIR,
	STONE,
	DIRT,
	GRASS,
	SAND,
	WATER
}

const STONE = Type.STONE
const DIRT = Type.DIRT
const GRASS = Type.GRASS
const SAND = Type.SAND
const WATER = Type.WATER
const AIR = Type.AIR

static func get_block_color(block_type: Type) -> Color:
	match block_type:
		Type.STONE:
			return Color.GRAY
		Type.DIRT:
			return Color(0.6, 0.4, 0.2)
		Type.GRASS:
			return Color.GREEN
		Type.SAND:
			return Color.YELLOW
		Type.WATER:
			return Color.BLUE
		_:
			return Color.WHITE

static func is_solid(block_type: Type) -> bool:
	return block_type != Type.AIR and block_type != Type.WATER
