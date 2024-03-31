extends TileMap

const tile_width: int = 64
const tile_size = Vector2i(tile_width, tile_width)
const width: int = 40
const height: int = 22
const unload_distance = width * 2
const spawn_size = 8

var player: CharacterBody2D
var static_body: StaticBody2D

var rock_noise_gen: FastNoiseLite = FastNoiseLite.new()
var dark_rock_noise_gen: FastNoiseLite = FastNoiseLite.new()
var lava_noise_gen: FastNoiseLite = FastNoiseLite.new()
var hard_lava_noise_gen: FastNoiseLite = FastNoiseLite.new()

var loaded_tiles = {}

func _ready():
	player = get_parent().get_node("Player")
	static_body = get_parent().get_node("StaticBody2D")

	rock_noise_gen.noise_type = FastNoiseLite.TYPE_VALUE
	rock_noise_gen.frequency = 0.2
	rock_noise_gen.seed = randi()

	dark_rock_noise_gen.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	dark_rock_noise_gen.frequency = 0.3
	dark_rock_noise_gen.seed = randi()

	lava_noise_gen.noise_type = FastNoiseLite.TYPE_SIMPLEX
	lava_noise_gen.frequency = 0.04
	lava_noise_gen.seed = randi()
	
	for x in range(-spawn_size, spawn_size):
		for y in range(-spawn_size, spawn_size):
			var tile_pos: Vector2i = Vector2i(x, y)
			set_tile_floor(tile_pos)

func _process(_delta):
	var player_tile_pos: Vector2i = player.position / Vector2(64, 64)
	generate_chunks(player_tile_pos)
	unload_distant_tiles(player_tile_pos)

func generate_chunks(player_tile_pos: Vector2i):
	@warning_ignore("integer_division")
	var start: Vector2i = player_tile_pos - Vector2i(width / 2, height / 2)
	@warning_ignore("integer_division")
	var end: Vector2i = player_tile_pos + Vector2i(width / 2, height / 2)
	
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var tile_pos: Vector2i = Vector2i(x, y)
			if loaded_tiles.has(tile_pos) || (abs(x) < 8 && abs(y) < 8):
				continue
			generate_tile(tile_pos)

func generate_tile(tile_pos):
	loaded_tiles[tile_pos] = null
	if has_rock(tile_pos):
		set_cell(0, tile_pos, randi_range(10, 11), Vector2(0, 0), 0)
		var collision_shape = make_collision_shape(tile_pos)
		loaded_tiles[tile_pos] = collision_shape
	elif has_dark_rock(tile_pos):
		set_cell(0, tile_pos, 12, Vector2(0, 0), 0)
		var collision_shape = make_collision_shape(tile_pos)
		loaded_tiles[tile_pos] = collision_shape
	elif has_lava(tile_pos):
		set_cell(0, tile_pos, randi_range(20, 21), Vector2(0, 0), 0)
		# set lava collider
	else:
		set_tile_floor(tile_pos)

func set_tile_floor(tile_pos):
	match randi_range(0, 100):
		var r when r < 90:
			set_cell(0, tile_pos, 0, Vector2(0, 0))
		_:
			set_cell(0, tile_pos, randi_range(0, 3), Vector2(0, 0))

func has_rock(tile_pos) -> bool:
	return (rock_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.60

func has_dark_rock(tile_pos) -> bool:
	return (dark_rock_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.80
	
func has_lava(tile_pos) -> bool:
	return (lava_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.67

func maybe_spawn_pickup(_tile_pos) -> bool:
	randi_range(0, 100)
	return false

func make_collision_shape(tile_pos: Vector2i):
	var rect: Shape2D = RectangleShape2D.new()
	rect.size = tile_size
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.shape = rect
	collision_shape.position = tile_pos as Vector2 * Vector2(64, 64)
	static_body.add_child(collision_shape)

func unload_distant_tiles(player_tile_pos):
	for tile in loaded_tiles:
		if distance(tile, player_tile_pos) > unload_distance:
			set_cell(0, tile, -1, Vector2(-1, -1), -1)
			var collision_shape = loaded_tiles[tile]
			static_body.remove_child(collision_shape)
			loaded_tiles.erase(tile)

func distance(p1, p2):
	var diff = p1 - p2
	return sqrt(diff.x ** 2 + diff.y ** 2)
