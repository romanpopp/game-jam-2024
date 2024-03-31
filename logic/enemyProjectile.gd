extends Area2D

@onready var player = get_tree().root.get_node("Main/Player")
var damage = 20
var speed = -300

func start(pos):
	position = pos
	var direction: Vector2 = position - player.position
	rotation = direction.angle()
	rotation -= PI / 2

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += global_transform.y * speed * delta 

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.call("take_damage", damage)
		queue_free()
