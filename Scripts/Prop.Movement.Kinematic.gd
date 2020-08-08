extends Node

export var gravity = -9.8
export var accel = 2
export var deaccel = 4

var speed = 0.0
var direction = Vector3()
var velocity = Vector3()

signal move_and_slide


func _get_speed():
	
	return velocity.length()


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_sidestep_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.rotation = new_rotation


func _turn(delta):
	
	owner.rotation.y += delta


func _set_horizontal_velocity(horizontal):
	
	horizontal = owner.global_transform.basis.xform(horizontal)
	velocity = Vector3(horizontal.x, velocity.y, horizontal.z)


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _physics_process(delta):
	
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	var new_velocity = owner.global_transform.basis.xform(direction) * speed
	var factor
	
	if new_velocity.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	velocity = horizontal.linear_interpolate(new_velocity, factor * delta)
	velocity.y += (delta * gravity)
	velocity = owner.move_and_slide(velocity, Vector3(0, 1, 0))
	
	emit_signal('move_and_slide', delta)
