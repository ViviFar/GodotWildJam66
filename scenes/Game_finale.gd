extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check lose con
	if $Swarm/Ants.get_child_count() <= 3:
		print("lost game")
		get_tree().change_scene_to_file("res://scenes/menu/game_over.tscn")
	var mainAntPos = $MainAnt.global_position
	if mainAntPos.distance_to($End.global_position) < 300:
		get_tree().change_scene_to_file("res://scenes/menu/win.tscn")
