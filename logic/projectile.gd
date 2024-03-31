extends Area2D
const Weapon = preload("res://logic/idEnum.gd").Weapon

@export var imgArray = []

# Variables set depending on weapon type at instantiation
var drag
var speed
var spread
var damage
var pierce
var knockback

@onready var spriteNode = get_node("Sprite2D")

# Sets up the position / rotation of this projectile
func start(type: Weapon, pos, boosted: bool):
	position = pos
	match type: 
		Weapon.default:
			spread = PI/16
			speed = randf_range(-600, -650)
			drag = -5
			damage = 1
			pierce = 0
			knockback = 0
			$Lifetime.wait_time = randf_range(0.8, 0.9)
			var spriteStr = load(imgArray[0])
			spriteNode.texture = spriteStr
		Weapon.cigarette:
			spread = PI/4
			speed = randf_range(-700, -900)
			drag = randf_range(-30, -15)
			damage = 1
			pierce = 10
			knockback = 0
			$Lifetime.wait_time = randf_range(1, 1.5)
			var spriteStr = load(imgArray[1])
			spriteNode.texture = spriteStr
		Weapon.stapler:
			spread = PI/32
			speed = -1300
			drag = 0
			damage = 4
			pierce = 2
			knockback = 20
			$Lifetime.wait_time = 1
			var spriteStr = load(imgArray[2])
			spriteNode.texture = spriteStr
		Weapon.toaster:
			spread = 0
			speed = -1000
			drag = 0
			damage = 2
			pierce = 0
			knockback = 3
			$Lifetime.wait_time = 0.5
			var spriteStr = load(imgArray[3])
			spriteNode.texture = spriteStr
			$Lifetime.start()
		_: print("no weapon type specified")
	if type != Weapon.toaster:
		look_at(get_global_mouse_position())
		rotate(PI/2 + randf()*spread - randf()*spread)
	$Lifetime.start()
	if boosted:
		damage += 3

# Bullet go shoot
func _process(delta):
	position += global_transform.y * speed * delta 
	if speed <= -20: 
		speed -= drag

# Detects when bullet goes offscreen
func _not_visible_on_screen():
	queue_free()

# Detects when the bullet's lifetime is over
func _on_lifetime_timeout():
	queue_free()

# Detects collisions
func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.call("take_damage", damage)
		body.call("knock_back", knockback*100)
		if pierce == 0: queue_free()
		pierce -= 1
