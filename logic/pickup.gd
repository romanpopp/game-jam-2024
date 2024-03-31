extends Area2D
const ID = preload("res://logic/idEnum.gd").ID

signal picked_up(ID)
@export var type: ID
@export var imgArray = []
@onready var PlayerNode = get_parent().get_node("Player")

# Sets up this pickup instance
func _ready():
	PlayerNode.connect("picked_up", PlayerNode._on_pick_up)

# Call this once on instantiation
func start(id: ID, pos):
	position = pos
	type = id
	var spriteStr = load(imgArray[type])
	get_node("Sprite2D").texture = spriteStr

# Detects when a body collides with this pickup
func _on_body_entered(body):
	if body.is_in_group("Player"):
		picked_up.emit(type)
		get_tree().root.get_node("Main/HUD").add_score(100)
		queue_free()
