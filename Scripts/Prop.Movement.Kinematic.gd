extends 'res://Scripts/Prop.Movement.gd'

export var process_movement = true
export var gravity = -9.8
export var accel = 3
export var deaccel = 5
export var angular_accel = 1.0
export var angular_deaccel = 1.0
export var projectile = false
export var ghost = false

var kinematic_collision

onready var collision = get_node_or_null('../Collision')

signal move_and_slide


func _get_collisions():
	
	return [kinematic_collision] if kinematic_collision else []


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


func _process(delta):
	
	if not process_movement or (collision and collision.disabled):
		return
	
	var new_velocity = angular_direction * delta
	var deltax = new_velocity.x - angular_velocity.x
	var deltay = new_velocity.y - angular_velocity.y
	var factorx
	var factory
	
	if (new_velocity.x > 0 and angular_velocity.x > 0) or (new_velocity.x < 0 and angular_velocity.x < 0):
		factorx = angular_accel
	else:
		factorx = angular_deaccel
	
	if (new_velocity.y > 0 and angular_velocity.y > 0) or (new_velocity.y < 0 and angular_velocity.y < 0):
		factory = angular_accel
	else:
		factory = angular_deaccel
	
	angular_velocity.x = angular_velocity.linear_interpolate(new_velocity, factorx * delta).x
	angular_velocity.y = angular_velocity.linear_interpolate(new_velocity, factory * delta).y
	
	
	owner.rotation.y += angular_velocity.x
	owner.rotation.x += angular_velocity.y
	
	if projectile:
		_set_direction(Vector3(0, 0, 1), true)


func _physics_process(delta):
	
	if not process_movement or (collision and collision.disabled):
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
	
	kinematic_collision = owner.move_and_collide(velocity, true, true, ghost)

	if kinematic_collision and not ghost:
		velocity = kinematic_collision.remainder

	emit_signal('move_and_slide', delta)
	
