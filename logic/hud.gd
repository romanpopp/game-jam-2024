extends CanvasLayer
const Weapon = preload("res://logic/idEnum.gd").Weapon

@onready var bar: TextureProgressBar = get_node("Healthbar")
@onready var node = get_node("WeaponDisplay/WeaponTexture")
@onready var ammoBar: TextureProgressBar = get_node("AmmoBar")
@onready var textBox = get_node("Text")
@onready var scoreText = get_node("Score")
@onready var scoreText2 = get_node("GameOver/GameOverScore")

@onready var breadBar: TextureProgressBar = get_node("BreadBar")
@onready var toasterDamage = get_node("ToastMeter")

var score = 0

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
			textBox.text = "Pocket Lint"
		Weapon.cigarette:
			node.texture = load("res://assets/weapons/cigarette.png")
			ammoBar.texture_progress = load("res://assets/hud/cigBurn.png")
			textBox.text = "Cigarette"
		Weapon.stapler:
			node.texture = load("res://assets/weapons/stapler.png")
			ammoBar.texture_progress = load("res://assets/hud/staplebar.png")
			textBox.text = "Stapler"
		Weapon.toaster:
			breadBar.visible = true
			toasterDamage.visible = true
			breadBar.value = 100
			toasterDamage.texture = load(toasterSprite[4])
			node.texture = load("res://assets/weapons/toasterOnGround.png")
			ammoBar.texture_progress = load("res://assets/blank.png")
			textBox.text = "Toaster"
	if type != Weapon.toaster:
		breadBar.visible = false
		toasterDamage.visible = false
	ammoBar.value = 100

func update_ammo(percent):
	ammoBar.value = percent

func update_toaster(toastCount, durabilityStage):
	if (durabilityStage < 0):
		change_weapon(Weapon.default)
	toasterDamage.texture = load(toasterSprite[durabilityStage])
	breadBar.value = toastCount

func add_score(amt):
	score += amt
	scoreText.text = str("Score: ", score)
	scoreText2.text = str("Score: ", score)

func _quit():
	get_tree().quit()
