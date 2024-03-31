extends CanvasLayer
const Weapon = preload("res://logic/idEnum.gd").Weapon

@onready var bar: TextureProgressBar = get_node("Healthbar")
@onready var node = get_node("WeaponDisplay/WeaponTexture")
@onready var ammoBar: TextureProgressBar = get_node("AmmoBar")

@onready var breadBar: TextureProgressBar = get_node("BreadBar")
@onready var toasterDamage = get_node("ToastMeter")

const toasterSprite = [
	"res://assets/hud/toaster5.png",
	"res://assets/hud/toaster4.png",
	"res://assets/hud/toaster3.png",
	"res://assets/hud/toaster2.png", 
	"res://assets/hud/toaster1.png", 
]

func health_change(amt):
	bar.value += amt

func change_weapon(type):
	match type:
		Weapon.default:
			node.texture = load("res://assets/particles/lint.png")
			ammoBar.texture_progress = load("res://assets/blank.png")
		Weapon.cigarette:
			node.texture = load("res://assets/weapons/cigarette.png")
			ammoBar.texture_progress = load("res://assets/hud/cigBurn.png")
		Weapon.stapler:
			node.texture = load("res://assets/weapons/stapler.png")
			ammoBar.texture_progress = load("res://assets/hud/staplebar.png")
		Weapon.toaster:
			breadBar.visible = true
			toasterDamage.visible = true
			breadBar.value = 100
			toasterDamage.texture = load(toasterSprite[4])
			node.texture = load("res://assets/weapons/toasterOnGround.png")
			ammoBar.texture_progress = load("res://assets/blank.png")
	if type != Weapon.toaster:
		breadBar.visible = false
		toasterDamage.visible = false
	ammoBar.value = 100

func update_ammo(percent):
	print(percent)
	ammoBar.value = percent

func update_toaster(toastCount, durabilityStage):
	if (durabilityStage < 0):
		change_weapon(Weapon.default)
	toasterDamage.texture = load(toasterSprite[durabilityStage])
	breadBar.value = toastCount

func _quit():
	get_tree().quit()
