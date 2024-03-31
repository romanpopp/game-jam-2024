extends Area2D
const Weapon = preload("res://logic/idEnum.gd").Weapon

@export var maxRotationRate = -20
@export var minRotationRate = 3
var rotationRate = minRotationRate
@export var damage = 1
@export var toastDamage = 2
@export var knockback = 20
var durability = 4
var shots = float(Weapon.toaster)
signal updateToasterUI(toastCount, durabilityStage)

@export var projectileScene: PackedScene

func start():
	updateToasterUI.connect(get_tree().root.get_node("Main/HUD").update_toaster)

func _physics_process(delta):
	if Input.is_action_pressed("shoot"):
		if rotationRate > maxRotationRate:
			rotationRate -= 5 * delta
		else:
			if randf() > 0.91 && shots > 0:
				shots -= 1
				updateToasterUI.emit(shots / Weapon.toaster * 100, durability)
				var projectile = projectileScene.instantiate()
				get_tree().root.add_child(projectile)
				projectile.start(Weapon.toaster, get_node("CollisionShape2D").global_position, false)
				projectile.rotation = rotation - 3 * PI / 4
	else:
		if rotationRate < minRotationRate:
			rotationRate += 10 * delta
	rotate(rotationRate * delta)

# Damageinator
func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.call("take_damage", damage)
		body.call("knock_back", knockback*100)
		if randf() > 0.84:
			durability -= 1
			updateToasterUI.emit(shots / Weapon.toaster * 100, durability)
			if durability < 0: queue_free()
