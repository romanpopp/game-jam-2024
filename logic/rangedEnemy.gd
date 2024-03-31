extends CharacterBody2D

# Health
@export var hp = 10
var damage = 20
var canShoot = false

@onready var player = get_parent().get_node("Player")
@onready var tiles: TileMap = get_parent().get_node("Tiles")
@export var projectileScene: PackedScene
const screen_tile_width = preload("res://logic/terrain.gd").screen_tile_width
const tile_size: Vector2 = preload("res://logic/terrain.gd").tile_size

func start(pos):
	position = pos
	$ShootCD.wait_time = randf_range(2.5, 2.8)
	$ShootCD.start()

func _physics_process(delta):
	var direction: Vector2 = player.position - position
	rotation = direction.angle()
	rotation -= PI / 2

func _process(delta):
	if distance(global_position, player.global_position) > screen_tile_width * tile_size.x:
		var new_pos: Vector2
		while (true):
			new_pos = Vector2i((Vector2(1, 0).rotated(randfn(0, 2 * PI)) * 10) + player.position / tile_size)
			if !tiles.contains_rock(new_pos):
				break
		position = new_pos * tile_size
	if !canShoot:
		return
	canShoot = false
	$ShootCD.wait_time = randf_range(2.5, 2.8)
	$ShootCD.start()
	instantiate_projectiles()

func distance(p1, p2):
	var diff = p1 - p2
	return sqrt(diff.x ** 2 + diff.y ** 2)

func instantiate_projectiles():
	var projectile = projectileScene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.start(position)

# Makes this enemy take damage
func take_damage(dmg):
	hp -= dmg
	if (hp <= 0): 
		get_tree().root.get_node("Main/HUD").add_score(300)
		queue_free()

# Knocks back the enemy
func knock_back(mag):
	velocity -= (player.position - position).normalized() * mag

# It's fucking 4:14 AM
func _on_shoot_cd_timeout():
	canShoot = true
