extends Node2D


const ID = preload("res://logic/idEnum.gd").ID
const ranged_enemy_scene = preload("res://rangedEnemy.tscn")
const enemy_scene = preload("res://basicEnemy.tscn")
const pickup_scene = preload("res://pickup.tscn")
const screen_tile_width = preload("res://logic/terrain.gd").screen_tile_width
const tile_size: Vector2 = preload("res://logic/terrain.gd").tile_size
const spawn_distance = Vector2(screen_tile_width,  screen_tile_width)

var player: CharacterBody2D
var tiles: TileMap
var last_nonzero_input_vector: Vector2 = Vector2(0, 0)
var frames_until_enemy_spawn = 0
var enemys_until_ranged = 0
var frames_until_item_spawn = 0

func _ready():
	player = get_node("Player")
	tiles = get_node("Tiles")

func _physics_process(delta):
	var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input_vector == Vector2(0, 0):
		return

	last_nonzero_input_vector = input_vector

	if frames_until_enemy_spawn == 0:
		var enemy_pos: Vector2
		while (true):
			enemy_pos = Vector2i((last_nonzero_input_vector.rotated(randfn(0, PI / 3)) * spawn_distance) + player.position / tile_size)
			if !tiles.contains_rock(enemy_pos):
				break
		var new_enemy
		if enemys_until_ranged == 0:
			new_enemy = ranged_enemy_scene.instantiate()
			enemys_until_ranged = 10
		else:
			new_enemy = enemy_scene.instantiate()
			enemys_until_ranged -= 1
		new_enemy.start(enemy_pos * tile_size)
		add_child(new_enemy)
		
	if frames_until_item_spawn == 0:
		var item_pos: Vector2
		while (true):
			item_pos = Vector2i((last_nonzero_input_vector.rotated(randfn(0, PI / 3)) * spawn_distance) + player.position / tile_size)
			if !tiles.contains_rock(item_pos):
				break
		var item_id
		match randi_range(0, 4):
			0:
				item_id = ID.dayquil
			1:
				item_id = ID.nyquil
			2:
				item_id = ID.cigarette
			3:
				item_id = ID.stapler
			4:
				item_id = ID.toaster
		var new_pickup = pickup_scene.instantiate()
		new_pickup.picked_up.connect(player._on_pick_up)
		new_pickup.start(item_id, item_pos * tile_size)
		add_child(new_pickup)
	
	if (frames_until_enemy_spawn == 0):
		frames_until_enemy_spawn = 50
	if (frames_until_item_spawn == 0):
		frames_until_item_spawn = 50
	frames_until_enemy_spawn -= 1
	frames_until_item_spawn -= 1
