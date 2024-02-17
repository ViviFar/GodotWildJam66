class_name ant
extends CharacterBody2D

@onready var ants = get_tree().get_nodes_in_group("ants")
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var mainAnt : Node2D

var neighbors
var neighbors_directions
var N = 20
var sigma_repulsion = 6.6
var weight_repulsion = 30.0
var weight_cohesion = 10.0
var weight_player = 100.0
var weight_stabilize = 20.0
var weight_random = 100.0

var f_r # repulsive
var f_c # cohesive
var f_p # player
var f_s # stabilize
var f_rand # random
var f_ext #external
var externalInfluence : Array[Vector3] # all external forces and their weight: the target is stored in x and y, the weight in z
var total_force
var new_velocity
var speed:float = 150
var accel:float = 7


func _ready():
	externalInfluence = []
	mainAnt= get_tree().get_first_node_in_group("mainAnt")
	set_physics_process(false)
	call_deferred("actor_setup")
	
func actor_setup()->void:
	await  get_tree().physics_frame
	ants.erase(self)
	for unique_ant in ants:
		unique_ant.connect("tree_exited", onAntDestroyed)
	set_physics_process(true)

func onAntDestroyed()->void:
	var tree = get_tree()
	if(tree):
		ants = tree.get_nodes_in_group("ants")
		ants.erase(self)
		if len(ants) > N:
			N = len(ants)


func find_neighbors():
	'''
	find the N closest ants, used for force computation
	'''
	neighbors = []
	var ant_dist
	var neighbor_dist
	var neighbor
	for unique_ant in ants:
		# If we do not have 6 neighbors yet, simply add it
		if len(neighbors) < N:
			neighbors.append(unique_ant)
			continue
		# compute distance to ant
		ant_dist = self.position.distance_to(unique_ant.position)
		# if the ant is closer than one of the current neighbor, take its spot
		for neighbor_index in len(neighbors):
			neighbor = neighbors[neighbor_index]
			neighbor_dist = self.position.distance_to(neighbor.position)
			if ant_dist < neighbor_dist:
				neighbors[neighbor_index] = unique_ant

func compute_neighbors_directions():
	neighbors_directions = []
	var direction
	for neighbor in neighbors:
		direction = (neighbor.position - self.position).normalized()
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
	
	
func compute_stabilize_force():
	'''
	Computes a force that slows down the general motion
	'''
	var f
	var velocity_norm = get_velocity().length() / (1 + get_velocity().length())
	f = -weight_stabilize*velocity_norm*get_velocity().normalized()
	return f
	
func compute_random_force():
	'''
	Computes a random force
	'''
	var f
	f = weight_random*Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	return f

func compute_external_forces() -> Vector2:
	var f : Vector2 = Vector2.ZERO
	if(len(externalInfluence)==0):
		return f
	for inf in externalInfluence:
		f= f+ inf.z * (Vector2(inf.x, inf.y) - self.global_position).normalized()
	return f

func goToTarget(delta: float) ->Vector2 :	
	var direction : Vector2 = Vector2()
	nav.target_position = mainAnt.position
	var targetLocation = nav.get_next_path_position()
	if(self.global_position.distance_to(mainAnt.position)>500):
		print("destroying " + self.name + " cuz of distance of " + str(self.global_position.distance_to(mainAnt.position)))
		self.queue_free()
	direction = (targetLocation-self.global_position).normalized()
	var error = self.global_position.distance_to(mainAnt.position)
	if error < 60: error = 0
	if error > 300: error = 300
	error = error / (1 + error) # map to 0-1
	var f  = weight_player *error*direction.normalized()
	return f

func AddExternalForce(origin : Vector2, weight: float) ->void:
	externalInfluence.append(Vector3(origin.x,origin.y, weight))

func RemoveExternalForce(origin:Vector2, weight:float) -> bool:
	var temp = Vector3(origin.x,origin.y,weight)
	if(externalInfluence.has(temp)):
		externalInfluence.erase(temp)
		return true
	return false

func _physics_process(delta):
	find_neighbors()
	compute_neighbors_directions()
	f_r = compute_repulsive_force()
	f_p = goToTarget(delta)
	f_s = compute_stabilize_force()
	f_rand = compute_random_force()
	f_ext = compute_external_forces()
	# print(f_r, f_p, f_s, f_rand)
	total_force = 10*(f_r + f_p +f_s + f_rand + f_ext)
	new_velocity = get_velocity() + (1/1.0)*total_force*delta
	if new_velocity.length() > 300.0: new_velocity = new_velocity.normalized()*300.0
	set_velocity(new_velocity)
	move_and_slide()
