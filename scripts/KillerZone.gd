extends Area2D

@export var timerBeforeDeath:float = 5
@onready var ants = get_tree().get_nodes_in_group("ants")
@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
