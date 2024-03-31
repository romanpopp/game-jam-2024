extends Node2D

# Everything you need to instantiate a Pickup
const ID = preload("res://logic/idEnum.gd").ID
const pickupScene = preload("res://pickup.tscn")
@onready var playerNode = get_node('Player')

func create_pickup(id, pos):
	var newPickup = pickupScene.instantiate()
	add_child(newPickup)
	newPickup.picked_up.connect(playerNode._on_pick_up)
	newPickup.start(id, pos)

# Everything you need to instantiate a Basic Enemy
const enemyScene = preload("res://basicEnemy.tscn")

func create_enemy(pos):
	var newEnemy = enemyScene.instantiate()
	add_child(newEnemy)
	newEnemy.start(pos)

func _ready():
	create_pickup(ID.dayquil, Vector2(100, 100))
	create_pickup(ID.nyquil, Vector2(200, 100))
	create_pickup(ID.cigarette, Vector2(300, 100))
	create_pickup(ID.stapler, Vector2(400, 100))
	create_pickup(ID.toaster, Vector2(500, 100))
	
	create_enemy(Vector2(-300, -300))
	create_enemy(Vector2(-500, -300))
	create_enemy(Vector2(-300, -500))
