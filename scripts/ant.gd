extends CharacterBody2D

@onready var ants = get_tree().get_nodes_in_group("ants")

var neighbors
var neighbors_directions
const N = 6
var sigma_repulsion = 1.0
var weight_repulsion = 1.0

var f_r
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
	Computes a force between 0 and 1 that goes in the opposite direction as the
	neighbors' average
	'''
	var f
	var s = Vector2(0,0)
	var dir
	var neighbor
	
	for neighbor_index in len(neighbors):
		dir = neighbors_directions[neighbor_index]
		neighbor = neighbors[neighbor_index]
		print(-self.position.distance_to(neighbor.position))
		s = s + dir*exp(-self.position.distance_to(neighbor.position)/sigma_repulsion**2)
	f = - weight_repulsion * s / N
	print(f)
	return f

func _physics_process(delta):
	find_neighbors()
	compute_neighbors_directions()
	f_r = compute_repulsive_force()
	total_force = 100*f_r
	new_velocity = get_velocity() + (1/1.0)*total_force*delta
	set_velocity(new_velocity)
	move_and_slide()
