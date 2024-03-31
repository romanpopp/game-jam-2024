extends CharacterBody2D

# Health
@export var hp = 10
var damage = 20
var canShoot = true

@onready var player = get_parent().get_node("Player")
@export var projectileScene: PackedScene

func start(pos):
	position = pos

func _physics_process(delta):
	var direction: Vector2 = player.position - position
	rotation = direction.angle()
	rotation -= PI / 2

func _process(delta):
	if !canShoot:
		return
	canShoot = false
	$ShootCD.wait_time = randf_range(2.5, 2.8)
	$ShootCD.start()
	instantiate_projectiles()

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
