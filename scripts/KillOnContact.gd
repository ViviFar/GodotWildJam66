extends RigidBody2D

func _on_body_entered(body):
	var antBody = body as ant
	if(antBody):
		antBody.queue_free()
