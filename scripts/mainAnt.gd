extends CharacterBody2D

@onready var tilemap : TileMap = get_tree().get_nodes_in_group("Tilemap")[0]

var speed : float = 150
var pheromoneLayer : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta : float):
	var tile_pos = tilemap.local_to_map(self.global_position)
	
func compute_player_direction() -> Vector2:
	'''
	Computes a force that goes towards player input direction
	'''
	var f = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		f.x -= 1
	if Input.is_action_pressed("ui_right"):
		f.x += 1
	if Input.is_action_pressed("ui_up"):
		f.y -= 1
	if Input.is_action_pressed("ui_down"):
		f.y += 1
	if(f!=Vector2.ZERO):
		f = f.normalized()
	return f

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var newSpeed : Vector2 =  compute_player_direction()
	newSpeed.x *= speed
	newSpeed.y *= speed
	self.velocity = newSpeed
	move_and_slide()
