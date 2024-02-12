extends CharacterBody2D

var speed:float = 200
var accel:float = 7

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func _ready():
	set_physics_process(false)
	call_deferred("actor_setup")
	
func actor_setup()->void:
	await  get_tree().physics_frame
	set_physics_process(true)

func findTarget() -> Vector2:
	var ants = get_tree().get_nodes_in_group("ants")
	#if we have at least one ant, we focus it. The get_global_mouse_position is for debug purpose in the spider only node
	#TODO link the findTarget to a signal so the code does not refer to ants at all
	if(ants):
		if(len(ants)>0):
			return ants[0].global_position	
	return get_global_mouse_position()

func _physics_process(delta) -> void:
	var direction : Vector2 = Vector2()
	
	# used for testing in own scene. 
	nav.target_position = findTarget()
	
	direction = (nav.get_next_path_position()-self.global_position).normalized()
	
	velocity = velocity.lerp(direction*speed, accel*delta)
	
	move_and_slide()
	
