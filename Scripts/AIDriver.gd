extends "res://Scripts/AnimationTree.gd"

var target
var drive_mode = Meta.DriverMode.Steer
var move_speed = 0
var turn_speed = 0


func _physics_process(delta):
	
	if drive_mode == Meta.DriverMode.Steer:
		
		owner.get_node('Movement')._set_direction_local(Vector3(0, 0, 1))
		owner.get_node('Movement')._face(target, turn_speed * delta)
	
	if drive_mode == Meta.DriverMode.Sidestep:
		
		owner.get_node('Movement')._set_direction(owner.direction_to(target))
		owner.get_node('Movement')._face(target, turn_speed * delta)
