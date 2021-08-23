extends 'res://Scripts/Prop.Movement.gd'

export var gravity = -300.0
export var accel = 3
export var deaccel = 5
export var ghost = false
export var stop_on_slope = false
export var max_slides = 4

signal move_and_slide


func _get_collisions():
	
	var collisions = []
	
	for index in range(owner.get_slide_count()):
		collisions.append(owner.get_slide_collision(index))
	
	return collisions


func _get_speed():
	
	return velocity.length()


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_sidestep_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _set_speed(new_speed):
	
	speed = new_speed


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _set_direction(new_direction, local=false):
	
	if local:
		direction = owner.global_transform.basis.xform(new_direction)
	else:
		direction = new_direction


func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.global_transform.basis = new_rotation


func _turn(delta):
	
	owner.rotation.y += delta


func _face(target, angle_delta=0.0):
	
	var owner_direction = owner.global_transform.basis.z
	var turn_target = owner.direction_to(target)
	turn_target.y = owner_direction.y
	
	var angle = owner_direction.angle_to(turn_target)
	
	if angle_delta == 0 or angle <= angle_delta:
		
		owner.global_transform.look_at(-turn_target)
	
	else:
		
		turn_target = owner.global_transform.basis.z.linear_interpolate(turn_target, angle_delta / angle)
		owner.global_transform.look_at(owner.global_transform.origin - turn_target)


func _physics_process(delta):
	
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	var new_velocity = direction * speed
	var factor
	
	if new_velocity.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	if factor > 0:
		velocity = horizontal.linear_interpolate(new_velocity, factor * delta)
	else:
		velocity = new_velocity
	
	velocity.y += (delta * gravity)
	
	
	if ghost:
		
		owner.move_and_slide(velocity, Vector3(0, 1, 0), stop_on_slope, max_slides)
		emit_signal('move_and_slide', delta)
		
	else:
		
		velocity = owner.move_and_slide(velocity, Vector3(0, 1, 0), stop_on_slope, max_slides)
		emit_signal('move_and_slide', delta)
