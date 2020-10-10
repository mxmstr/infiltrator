extends "res://Scripts/AnimationTree.gd"


var target
var move_speed = 0
var turn_speed = 0


func _physics_process(delta):
	
	if turn_speed > 0:
	
		var owner_direction = owner.global_transform.basis.z
		var turn_target = owner.direction_to(target)
		var angle = owner_direction.angle_to(turn_target)
		var angle_delta  = turn_speed * delta
		
		if angle > angle_delta:
			
			turn_target = owner.global_transform.basis.z.linear_interpolate(turn_target, angle / angle_delta)
			owner.global_transform.look_at(owner.global_transform.origin - turn_target)
		
		else:
			
			owner.global_transform.look_at(-turn_target)