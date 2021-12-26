extends 'res://Scripts/Prop.Movement.gd'

export var gravity = -9.8
export var accel = 3.0
export var deaccel = 5.0
export var angular_accel = 0.1
export var angular_deaccel = 10
export var stop_on_slope = false
export var max_slides = 4

var rotate_x_camera = false
var rotate_y_camera = true
var snap = Vector3()

onready var camera_rig = get_node_or_null('../CameraRig')

signal move_and_slide


func _get_collisions():
	
	var collisions = []
	
	for index in range(owner.get_slide_count()):
		collisions.append(owner.get_slide_collision(index))
	
	return collisions


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_sidestep_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _apply_root_transform(root_transform, delta):
	
	owner.transform *= root_transform


func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.global_transform.basis = new_rotation


func _turn(delta):
	
	angular_direction.x = delta


func _look(delta):
	
	angular_direction.y = delta


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


func _apply_rotation(delta):
	
	var new_velocity = angular_direction * delta
	var deltax = new_velocity.x - angular_velocity.x
	var deltay = new_velocity.y - angular_velocity.y
	var factorx
	var factory
	var factor
	
	if Vector2(new_velocity.x, 0).dot(Vector2(angular_velocity.x, 0)) <= 0:# or (new_velocity.x > 0 and angular_velocity.x < 0) or (new_velocity.x < 0 and angular_velocity.x > 0):
		factorx = angular_deaccel
	else:
		factorx = angular_accel

	if Vector2(0, new_velocity.y).dot(Vector2(0, angular_velocity.y)) <= 0:# or (new_velocity.y > 0 and angular_velocity.y < 0) or (new_velocity.y < 0 and angular_velocity.y > 0):
		factory = angular_deaccel
	else:
		factory = angular_accel

	angular_velocity.x = angular_velocity.linear_interpolate(new_velocity, factorx * delta).x
	angular_velocity.y = angular_velocity.linear_interpolate(new_velocity, factory * delta).y
	
#	if new_velocity.dot(angular_velocity) > 0:
#		factor = angular_accel
#	else:
#		factor = angular_deaccel
#
#	angular_velocity = angular_velocity.linear_interpolate(new_velocity, factor * delta)
	
	if rotate_x_camera:
		camera_rig._rotate_camera(angular_velocity.y, angular_velocity.x)
	else:
		owner.rotation.y += angular_velocity.x
		camera_rig._rotate_camera(angular_velocity.y, 0.0)


func _physics_process(delta):
	
	_apply_rotation(delta)
	
	
	var vertical = velocity.y# + (delta * gravity)
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
	
	velocity.y = vertical
	
	
	if owner.is_on_floor() and velocity.y <= 0:
		var length = Vector3(velocity.x, 0, velocity.z).length()
		velocity = velocity.normalized() * length
	else:
		velocity = Vector3(velocity.x, velocity.y + (gravity * delta), velocity.z)
	
	# Calc snap value
	if owner.is_on_floor() and velocity.y <= 0:    
		snap = -owner.get_floor_normal() - owner.get_floor_velocity() * delta
	else:
		snap = Vector3.ZERO

	# Apply velocity
	velocity = owner.move_and_slide_with_snap(velocity, snap, Vector3.UP, stop_on_slope)
	
	
	emit_signal('move_and_slide', delta)
