extends Area2D

@export var weight : float
@export var maxNumberOfAttractedAnts = 6
var nbOfAttractedAnts : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	var antbody : ant = body as ant
		
	if(antbody):
		if(weight>0): #if the obstacle is an attractive one, we limit the number of ants that can be affected
			nbOfAttractedAnts+=1
			if(nbOfAttractedAnts>maxNumberOfAttractedAnts):
				return
		antbody.AddExternalForce(self.global_position, weight)


func _on_body_exited(body):
	var antbody : ant = body as ant
	
	if(antbody):
		if(antbody.RemoveExternalForce(self.global_position, weight)):
			nbOfAttractedAnts-=1
