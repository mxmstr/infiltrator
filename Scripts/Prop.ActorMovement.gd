extends Node

export var gravity = -9.8
export var max_speed = 5
export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

var direction = Vector3()
var velocity = Vector3()


func _physics_process(delta):
	
	velocity.y += delta * gravity
	
	var hvelocity = velocity
	hvelocity.y = 0
	
	var target = direction * max_speed
	
	var factor
	if direction.dot(hvelocity) > 0:
		factor = accel
	else:
		factor = deaccel
	
	hvelocity = hvelocity.linear_interpolate(target, factor * delta)
	
	velocity.x = hvelocity.x
	velocity.z = hvelocity.z

	velocity = get_parent().move_and_slide(velocity, Vector3(0, 1, 0))