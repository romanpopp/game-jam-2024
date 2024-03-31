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
signal healthChange(amt)

# Stat buff variables
var speedBoost = false
var damageBoost = false
@onready var boostParticles = get_node('BoostParticles')
@onready var damageParticles = get_node('DamageParticles')
var dead = false

# Weapon settings
@export var projectileScene: PackedScene
@export var toasterScene: PackedScene
var currentWeapon = Weapon.default
var canShoot = true
var durability: float = 0.0
var maxDurability: float = 0.0
var toasterObject = null
signal changeWeaponUI(type)
signal updateAmmoUI(percent)

# Animation settings
@onready var sprite = get_node("AnimatedSprite2D")

# Set timer wait times
func _ready():
	$DodgeCD.wait_time = dodgeCD
	healthChange.connect(get_tree().root.get_node("Main/HUD").health_change)
	changeWeaponUI.connect(get_tree().root.get_node("Main/HUD").change_weapon)
	updateAmmoUI.connect(get_tree().root.get_node("Main/HUD").update_ammo)

# Checking for button presses
func _process(delta):
	if Input.is_action_pressed("dodge"):
		dodge()
	if Input.is_action_pressed("shoot"):
		shoot()
	if durability <= 0:
		durability = 0
		currentWeapon = Weapon.default
		changeWeaponUI.emit(Weapon.default)
		$ShootCD.wait_time = 0.8
	
	# 4:44AM toaster check
	if toasterObject == null && currentWeapon == Weapon.toaster:
		currentWeapon = Weapon.default
		changeWeaponUI.emit(Weapon.default)
	
	# Durability for cigarette
	if currentWeapon == Weapon.cigarette:
		durability -= delta
		updateAmmoUI.emit(durability / maxDurability * 100)
	animation()

# Physics processing
func _physics_process(delta):
	if speed >= defaultSpeed:
		boostParticles.emitting = true
		speed -= 6
	else: boostParticles.emitting = false
	velocity += Input.get_vector("left", "right", "up", "down") * delta * speed
	velocity -= velocity * delta * friction
	move_and_slide()

func animation():
	if Input.is_action_pressed("down"):
		sprite.play("down")
	else: if Input.is_action_pressed("up"):
		sprite.play("up")
	else: if Input.is_action_pressed("left"):
		sprite.play("left")
	else: if Input.is_action_pressed("right"):
		sprite.play("right")
	else:
		sprite.play("default")

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
			instantiate_projectiles(3)
		Weapon.cigarette:
			instantiate_projectiles(randi_range(7, 12))
		Weapon.stapler:
			instantiate_projectiles(1)
			durability -= 1
			updateAmmoUI.emit(durability / maxDurability * 100)
		Weapon.toaster:
			pass

# Gets ID enum from pickup
func _on_pick_up(id):
	match id:
		ID.dayquil: # Health up and temporary speed boost
			speed = defaultSpeed * speedMultiplier
			take_damage(-15)
		ID.nyquil: # Greater health up and temporary damage boost
			damageBoost = true
			$DmgBoostTimer.start()
			damageParticles.emitting = true
			take_damage(-25)
		ID.cigarette: # Fires 3-5 ash projectiles that burn, has a timer
			if toasterObject != null:
				toasterObject.queue_free()
			currentWeapon = Weapon.cigarette
			durability = int(Weapon.cigarette)
			maxDurability = int(Weapon.cigarette)
			$ShootCD.wait_time = 0.6
			changeWeaponUI.emit(Weapon.cigarette)
		ID.stapler: # Fires large staples that knock back, has limited ammo
			if toasterObject != null:
				toasterObject.queue_free()
			currentWeapon = Weapon.stapler
			durability = int(Weapon.stapler)
			maxDurability = int(Weapon.stapler)
			$ShootCD.wait_time = 0.4
			changeWeaponUI.emit(Weapon.stapler)
		ID.toaster: # Melee flail weapon, has limited durability
			if toasterObject != null:
				toasterObject.queue_free()
			currentWeapon = Weapon.toaster
			durability = int(Weapon.toaster)
			maxDurability = int(Weapon.toaster)
			changeWeaponUI.emit(Weapon.toaster)
			toasterObject = toasterScene.instantiate()
			add_child(toasterObject)
			toasterObject.start()
		_: print("no ID")

func instantiate_projectiles(n: int):
	for i in range(0, n):
		var projectile = projectileScene.instantiate()
		get_tree().root.add_child(projectile)
		projectile.start(currentWeapon, position, damageBoost)

func take_damage(dmg):
	hp -= dmg
	healthChange.emit(-dmg)
	if hp <= 0:
		get_tree().root.get_node("Main/HUD/GameOver").visible = true
		speed = 0
		canShoot = false
		dead = true

# Called by DodgeCD timer after timeout
func _on_dodge_cd_timeout():
	canDodge = true

# Called by ShootCD timer after timeout
func _on_shoot_cd_timeout():
	if dead:
		return
	canShoot = true

# Called by DmgBoostTimer after timeout
func _on_dmg_boost_timeout():
	damageBoost = false
	damageParticles.emitting = false

func _on_lava_area_body_entered(body):
	if body.is_in_group("Player"):
		take_damage(5)
