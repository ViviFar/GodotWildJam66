extends CharacterBody2D
#this class should replace CharacterBody2D in the extend for ants and spider but for whatever reason, it says class can not be found.
#Given that it's a jam, I'll leave it there but will go the ugly way cuz time


var speed:float = 200
var accel:float = 7
var target : Node2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D

func findTarget() -> Vector2:
	push_error("UNIMPLEMENTED ERROR: navigationBody2D.findTarget")
	return Vector2.ZERO
	
func goToTarget(delta: float) ->void :	
	var direction : Vector2 = Vector2()
	nav.target_position = findTarget()	
	direction = (nav.get_next_path_position()-self.global_position).normalized()	
	velocity = velocity.lerp(direction*speed, accel*delta)

