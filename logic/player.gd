extends CharacterBody2D
const ID = preload("res://logic/idEnum.gd").ID
const Weapon = preload("res://logic/idEnum.gd").Weapon

# Speed and dodge settings
@export var defaultSpeed = 5000
@export var dodgeCD = 2
@export var dodgeSpeed = 5
@export var speedMultiplier = 2
var speed = defaultSpeed
var accel = speed * 10
@warning_ignore("integer_division")
var friction = accel / speed
var canDodge = true

# HP settings
@export var hp = 100

# Stat buff variables
var speedBoost = false
var damageBoost = false
@onready var boostParticles = get_node('BoostParticles')
@onready var damageParticles = get_node('DamageParticles')

# Weapon settings
@export var projectileScene: PackedScene
var currentWeapon = Weapon.default
var canShoot = true
var durability = 0

# Set timer wait times
func _ready():
	$DodgeCD.wait_time = dodgeCD

# Checking for button presses
func _process(delta):
	if Input.is_action_pressed("dodge"):
		dodge()
	if Input.is_action_pressed("shoot"):
		shoot()
	if durability <= 0:
		durability = 0
		currentWeapon = Weapon.default
		$ShootCD.wait_time = 0.8
	
	# Durability for cigarette
	if currentWeapon == Weapon.cigarette:
		durability -= delta

# Physics processing
func _physics_process(delta):
	if speed >= defaultSpeed:
		boostParticles.emitting = true
		speed -= 6
	else: boostParticles.emitting = false
	velocity += Input.get_vector("left", "right", "up", "down") * delta * speed
	velocity -= velocity * delta * friction
	move_and_slide()

# Dodge function
func dodge():
	if !canDodge:
		return
	canDodge = false
	$DodgeCD.start()
	velocity += velocity * dodgeSpeed

# Shoot function
func shoot():
	if !canShoot:
		return
	canShoot = false
	$ShootCD.start()
	match currentWeapon:
		Weapon.default:
			instantiate_projectiles(2)
		Weapon.cigarette:
			instantiate_projectiles(randi_range(4, 7))
		Weapon.stapler:
			instantiate_projectiles(1)
			durability -= 1
		Weapon.toaster:
			pass

# Gets ID enum from pickup
func _on_pick_up(id):
	match id:
		ID.dayquil: # Health up and temporary speed boost
			speed = defaultSpeed * speedMultiplier
		ID.nyquil: # Greater health up and temporary damage boost
			damageBoost = true
			$DmgBoostTimer.start()
			damageParticles.emitting = true
		ID.cigarette: # Fires 3-5 ash projectiles that burn, has a timer
			currentWeapon = Weapon.cigarette
			durability = int(Weapon.cigarette)
			$ShootCD.wait_time = 0.6
		ID.stapler: # Fires large staples that knock back, has limited ammo
			currentWeapon = Weapon.stapler
			durability = int(Weapon.stapler)
			$ShootCD.wait_time = 0.4
		ID.toaster: # Melee flail weapon, has limited durability
			currentWeapon = Weapon.toaster
			durability = int(Weapon.toaster)
		_: print("no ID")

func instantiate_projectiles(n: int):
	for i in range(0, n):
		var projectile = projectileScene.instantiate()
		get_tree().root.add_child(projectile)
		projectile.start(currentWeapon, position, damageBoost)

func take_damage(dmg):
	hp -= dmg
	print (hp)

# Called by DodgeCD timer after timeout
func _on_dodge_cd_timeout():
	canDodge = true

# Called by ShootCD timer after timeout
func _on_shoot_cd_timeout():
	canShoot = true


func _on_dmg_boost_timeout():
	damageBoost = false
	damageParticles.emitting = false
