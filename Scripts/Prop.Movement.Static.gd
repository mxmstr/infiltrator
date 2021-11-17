extends 'res://Scripts/Prop.Movement.gd'

export var process_movement = false
export var gravity = 0
export var accel = 0
export var deaccel = 0

signal before_move
signal after_move


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_sidestep_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


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
	
	if not process_movement:
		return
	
	
	var new_velocity = direction * speed * delta
	var factor
	
	if new_velocity.dot(velocity) > 0:
		factor = accel
	else:
		factor = deaccel
	
	if factor > 0:
		velocity = velocity.linear_interpolate(new_velocity, factor * delta)
	else:
		velocity = new_velocity
	
	velocity.y += (delta * gravity)
	
	emit_signal('before_move', velocity)
	
	owner.global_translate(velocity)
	
	emit_signal('after_move', velocity)
	
