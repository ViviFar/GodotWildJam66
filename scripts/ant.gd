extends CharacterBody2D

@onready var ants = get_tree().get_nodes_in_group("ants")

var neighbors
var neighbors_directions
const N = 10
var sigma_repulsion = 4.6
var weight_repulsion = 1.0
var weight_cohesion = 2.0
var weight_player = 1.0

var f_r
var f_c
var f_p
var total_force
var new_velocity

func _ready():
	ants.erase(self)

func find_neighbors():
	'''
	find the 6 closest ants, used for force computation
	'''
	neighbors = []
	var ant_dist
	var neighbor_dist
	var neighbor
	for ant in ants:
		# If we do not have 6 neighbors yet, simply add it
		if len(neighbors) < N:
			neighbors.append(ant)
			continue
		# compute distance to ant
		ant_dist = self.position.distance_to(ant.position)
		# if the ant is closer than one of the current neighbor, take its spot
		for neighbor_index in len(neighbors):
			neighbor = neighbors[neighbor_index]
			neighbor_dist = self.position.distance_to(neighbor.position)
			if ant_dist < neighbor_dist:
				neighbors[neighbor_index] = ant

func compute_neighbors_directions():
	neighbors_directions = []
	var direction
	for neighbor in neighbors:
		direction = (neighbor.position - self.position) / self.position.distance_to(neighbor.position)
		neighbors_directions.append(direction)

func compute_repulsive_force():
	'''
	Computes a force that goes in the opposite direction as the
	neighbors' average
	'''
	var f
	var s = Vector2(0.0, 0.0)
	var dir
	var neighbor
	
	for neighbor_index in len(neighbors):
		dir = neighbors_directions[neighbor_index]
		neighbor = neighbors[neighbor_index]
		s = s + dir*exp(-self.position.distance_to(neighbor.position)/sigma_repulsion**2)
	f = - weight_repulsion * s / N
	return f
	
func compute_cohesive_force():
	'''
	Computes a force that goes towards neighbors'
	center of gravity
	'''
	var f
	var s = Vector2(0.0, 0.0)
	var dir
	for neighbor_index in len(neighbors):
		dir = neighbors_directions[neighbor_index]
		s = s + dir
	f = weight_cohesion * s / N
	return f

func compute_player_force():
	'''
	Computes a force that goes towards player input direction
	'''
	var f = Vector2()
	if Input.is_action_pressed("ui_left"):
		f.x -= 1
	if Input.is_action_pressed("ui_right"):
		f.x += 1
	if Input.is_action_pressed("ui_up"):
		f.y -= 1
	if Input.is_action_pressed("ui_down"):
		f.y += 1
	f = weight_player * f
	return f

func _physics_process(delta):
	find_neighbors()
	compute_neighbors_directions()
	f_r = compute_repulsive_force()
	f_c = compute_cohesive_force()
	f_p = compute_player_force()
	total_force = 10*(f_r + f_c + f_p)
	new_velocity = get_velocity() + (1/1.0)*total_force*delta
	set_velocity(new_velocity)
	move_and_slide()
