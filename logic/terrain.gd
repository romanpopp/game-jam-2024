extends TileMap

const tile_width: int = 64
const tile_size = Vector2i(tile_width, tile_width)
const screen_tile_width: int = 42
const screen_tile_height: int = 24
const unload_distance = screen_tile_width * 1.2
const spawn_size = 8

var player: CharacterBody2D
var tile_static_body: StaticBody2D
var lava_area: Area2D

var rock_noise_gen: FastNoiseLite = FastNoiseLite.new()
var rare_rock_noise_gen: FastNoiseLite = FastNoiseLite.new()
var lava_noise_gen: FastNoiseLite = FastNoiseLite.new()

var loaded_tiles = {}

func _ready():
	var p = get_parent()
	player = p.get_node("Player")
	tile_static_body = p.get_node("TileStaticBody")
	lava_area = p.get_node("LavaArea")

	rock_noise_gen.noise_type = FastNoiseLite.TYPE_VALUE
	rock_noise_gen.frequency = 0.2
	rock_noise_gen.seed = randi()

	rare_rock_noise_gen.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rare_rock_noise_gen.frequency = 0.3
	rare_rock_noise_gen.seed = randi()

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
	var start: Vector2i = player_tile_pos - Vector2i(screen_tile_width / 2, screen_tile_height / 2)
	@warning_ignore("integer_division")
	var end: Vector2i = player_tile_pos + Vector2i(screen_tile_width / 2, screen_tile_height / 2)
	
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			var tile_pos: Vector2i = Vector2i(x, y)
			if loaded_tiles.has(tile_pos) || (abs(x) < spawn_size && abs(y) < spawn_size):
				continue
			generate_tile(tile_pos)

func generate_tile(tile_pos):
	loaded_tiles[tile_pos] = null
	if has_rock(tile_pos):
		set_cell(0, tile_pos, randi_range(10, 11), Vector2(0, 0))
		set_collision_for_tile(tile_static_body, tile_pos)
	elif has_rare_rock(tile_pos):
		set_cell(0, tile_pos, randi_range(30, 31), Vector2(0, 0))
		set_collision_for_tile(tile_static_body, tile_pos)
	elif has_lava(tile_pos):
		set_cell(0, tile_pos, randi_range(20, 22), Vector2(0, 0))
		set_collision_for_tile(lava_area, tile_pos)
	else:
		set_tile_floor(tile_pos)

func set_tile_floor(tile_pos):
	match randi_range(0, 100):
		var r when r > 99:
			set_cell(0, tile_pos, 3, Vector2(0, 0))
		var r when r > 70:
			set_cell(0, tile_pos, randi_range(1, 2), Vector2(0, 0))
		_:
			set_cell(0, tile_pos, 0, Vector2(0, 0))

func has_rock(tile_pos) -> bool:
	return (rock_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.60

func has_rare_rock(tile_pos) -> bool:
	return (rare_rock_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.80
	
func has_lava(tile_pos) -> bool:
	return (lava_noise_gen.get_noise_2d(tile_pos.x, tile_pos.y) + 1) / 2 > 0.67

func maybe_spawn_pickup(_tile_pos) -> bool:
	randi_range(0, 100)
	return false

func set_collision_for_tile(parent: CollisionObject2D, tile_pos: Vector2i):
	var rect: Shape2D = RectangleShape2D.new()
	rect.size = tile_size
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	collision_shape.shape = rect
	collision_shape.position = tile_pos * tile_size
	loaded_tiles[tile_pos] = collision_shape
	parent.add_child(collision_shape)

func unload_distant_tiles(player_tile_pos):
	for tile in loaded_tiles:
		if distance(tile, player_tile_pos) > unload_distance:
			set_cell(0, tile, -1, Vector2(-1, -1), -1)
			var collision_shape = loaded_tiles[tile]
			tile_static_body.remove_child(collision_shape)
			lava_area.remove_child(collision_shape)
			loaded_tiles.erase(tile)

func distance(p1, p2):
	var diff = p1 - p2
	return sqrt(diff.x ** 2 + diff.y ** 2)

func contains_rock(tile_pos: Vector2i):
	return has_rock(tile_pos) or has_rare_rock(tile_pos)
