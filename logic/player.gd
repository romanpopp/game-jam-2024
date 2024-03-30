extends CharacterBody2D

# Visible in editor
@export var speed = 5000
@export var dodgeCD = 2
@export var dodgeSpeed = 800

@warning_ignore("integer_division")
var accel = speed * 10
var friction = accel / speed

var canDodge = true

func _ready():
	$DodgeCD.wait_time = dodgeCD

func _process(delta):
	if Input.is_action_pressed("dodge"):
		dodge(delta)

func _physics_process(delta):
	velocity += Input.get_vector("left", "right", "up", "down") * delta * speed
	velocity -= velocity * delta * friction
	move_and_slide()

# Dodge function
func dodge(delta):
	if not canDodge:
		return
	canDodge = false
	velocity += velocity * dodgeSpeed * delta
	$DodgeCD.start()

# Called by DodgeCD timer after timeout
func _on_dodge_cd_timeout():
	canDodge = true
