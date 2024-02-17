extends CharacterBody2D

@onready var tilemap : TileMap = get_tree().get_nodes_in_group("Tilemap")[0]
@onready var ants = get_tree().get_nodes_in_group("ants")
@export var timeBeforeDeathOutsidePheromone : float = 10

var speed : float = 150
var pheromoneLayer : int = 0
var timer : float = 0
var IsOnPheromone = "IsOnPheromone"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta : float):
	var tile_pos : Vector2i = tilemap.local_to_map(self.global_position)
	var tile_data : TileData = tilemap.get_cell_tile_data(pheromoneLayer,tile_pos)
	if(tile_data):
		var isOnPheromone = tile_data.get_custom_data(IsOnPheromone)
		if(!isOnPheromone):
			timer+=_delta
			if(timer>timeBeforeDeathOutsidePheromone):
				ants = get_tree().get_nodes_in_group("ants")
				var index = randi()%len(ants)
				ants[index].queue_free()
				timer = 0
		else:
			timer = 0

	
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
