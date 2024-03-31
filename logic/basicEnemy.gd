extends CharacterBody2D

# Movement variables
var defaultSpeed = 1700
var speed = defaultSpeed
var accel = speed * 10
@warning_ignore("integer_division")
var friction = accel / speed
var wandering = false
var wanderDirection

# Health
@export var hp = 6
var damage = 10

@onready var player = get_parent().get_node("Player")

func start(pos):
	position = pos

func _physics_process(delta):
	var direction: Vector2 = player.position - position
	rotation = direction.angle()
	rotation -= PI / 2
	
	if wandering:
		velocity += wanderDirection * speed * delta
		velocity -= velocity * friction * delta
	else:
		velocity += direction.normalized() * speed * delta
		velocity -= velocity * friction * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision != null && !wandering:
		if collision.get_collider().is_in_group("Player"):
			collision.get_collider().call("take_damage", damage) # makes player take damage
		wanderDirection = -direction.normalized()
		speed *= 1.5
		wandering = true
		$WanderTime.wait_time = randf_range(0.3, 0.5)
		$WanderTime.start()

# Makes this enemy take damage
func take_damage(dmg):
	hp -= dmg
	if (hp <= 0): queue_free()

# Knocks back the enemy
func knock_back(mag):
	velocity -= (player.position - position).normalized() * mag

# Called when wander timer ends
func _on_wander_time_timeout():
	wandering = false
	speed = defaultSpeed
