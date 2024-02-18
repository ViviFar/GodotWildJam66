extends CharacterBody2D

var speed:float = 525
var accel:float = 50
var distMax :float = 1200
var target : Node2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var _animated_sprite = $AnimatedSprite2D
var anim_delay : float = randf_range(0.0, 1.0)
var anim_flag : bool = false

func _ready():
	set_physics_process(false)
	call_deferred("actor_setup")
	
func actor_setup()->void:
	await  get_tree().physics_frame
	set_physics_process(true)

func findTarget() -> Vector2:
	if(target):
		return target.global_position
	var ants = get_tree().get_nodes_in_group("ants")
	#if we have at least one ant, we focus it. The get_global_mouse_position is for debug purpose in the spider only node
	#TODO link the findTarget to a signal so the code does not refer to ants at all
	if(ants):
		if(len(ants)>0):
			var targetIndex : int = randi() % len(ants)			
			target = ants[targetIndex]
			target.connect("tree_exiting", destroyTarget)
			return target.global_position
	#used for testing purpose on spider scene
	return get_global_mouse_position()

func destroyTarget()->void:
	target = null

func eat() -> void:
	if(!target):
		return
	print("eating " + target.name)
	target.queue_free()
	target = null
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	set_physics_process(true)
	

func goToTarget(delta: float) ->void :	
	var direction : Vector2 = Vector2()
	nav.target_position = findTarget()	
	direction = (nav.get_next_path_position()-self.global_position).normalized()	
	velocity = velocity.lerp(direction*speed, accel*delta)

func _physics_process(delta: float) -> void:
	if(target && self.global_position.distance_to(target.global_position)>distMax):
			return
	goToTarget(delta)
	if(nav.is_target_reached() || self.global_position.distance_to(nav.target_position)<=100):
		eat()
	
	move_and_slide()
	
func _process(_delta):
	if not anim_flag:
		await get_tree().create_timer(anim_delay).timeout
		anim_flag = true
	_animated_sprite.play("default")
	_animated_sprite.play("default")
	

