extends Node




func _on_enter():
	
	pass


func _on_execute(velocity):
	
	var current_pos = get_parent().global_transform.origin
	
	
#	velocity.y += delta * gravity
#
#	var hvelocity = velocity
#	hvelocity.y = 0
#
#
#	var target = Vector3()
#
#	get_parent().global_transform.origin = current_pos.linear_interpolate(climb_target, climb_progress)
#
#	velocity.x = 0
#	velocity.z = 0
#
#	var factor
#
#	if direction.dot(hvelocity) > 0:
#		factor = accel
#	else:
#		factor = deaccel
#
#	hvelocity = hvelocity.linear_interpolate(target, factor * delta)
#
#	velocity.x = hvelocity.x
#	#velocity.y = hvelocity.y
#	velocity.z = hvelocity.z
#
#	velocity = get_parent().move_and_slide(velocity, Vector3(0, 1, 0))


func _on_exit():
	
	pass