extends 'res://Scripts/Prop.Movement.gd'

const accel = 2.0
const deaccel = 5.0
const angular_accel = 0.04#0.05
const angular_deaccel = 9.0

export var gravity = -9.8
export var vertical_speed_mult = 0.5
export var stop_on_slope = false
export var max_slides = 4

var angular_velocity_x_pos = 0.0
var angular_velocity_x_neg = 0.0
var angular_velocity_y_pos = 0.0
var angular_velocity_y_neg = 0.0
var rotate_x_camera = false
var rotate_y_camera = true
var snap = Vector3()
var factorx = angular_deaccel
var factory = angular_deaccel

onready var camera_rig = get_node_or_null('../CameraRig')
onready var bullet_time = get_node_or_null('../BulletTime')

signal move_and_slide


func _get_collisions():
	
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
	var x_positive = new_velocity.x if new_velocity.x > 0 else 0
	var x_negative = new_velocity.x if new_velocity.x < 0 else 0
	var y_positive = new_velocity.y if new_velocity.y > 0 else 0
	var y_negative = new_velocity.y if new_velocity.y < 0 else 0
	
	var deltax = new_velocity.x - angular_velocity.x
	var deltax_positive = deltax if deltax > 0 else 0
	var deltax_negative = deltax if deltax < 0 else 0
	var deltay = new_velocity.y - angular_velocity.y
	var deltay_positive = deltay if deltay > 0 else 0
	var deltay_negative = deltay if deltay < 0 else 0
	
	var factorx_positive = angular_accel if deltax_positive else angular_deaccel
	var factorx_negative = angular_accel if deltax_negative else angular_deaccel
	var factory_positive = angular_accel if deltay_positive else angular_deaccel
	var factory_negative = angular_accel if deltay_negative else angular_deaccel
	
	angular_velocity_x_pos = Vector2(angular_velocity_x_pos, 0).linear_interpolate(Vector2(x_positive, 0), factorx_positive * delta).x
	angular_velocity_x_neg = Vector2(angular_velocity_x_neg, 0).linear_interpolate(Vector2(x_negative, 0), factorx_negative * delta).x
	angular_velocity.x = angular_velocity_x_pos + angular_velocity_x_neg
	angular_velocity_y_pos = Vector2(0, angular_velocity_y_pos).linear_interpolate(Vector2(0, y_positive), factory_positive * vertical_speed_mult * delta).y
	angular_velocity_y_neg = Vector2(0, angular_velocity_y_neg).linear_interpolate(Vector2(0, y_negative), factory_negative * vertical_speed_mult * delta).y
	angular_velocity.y = angular_velocity_y_pos + angular_velocity_y_neg
	
	if rotate_x_camera:
		camera_rig._rotate_camera(angular_velocity.y, angular_velocity.x)
	else:
		owner.rotation.y += angular_velocity.x
		camera_rig._rotate_camera(angular_velocity.y, 0.0)


func _physics_process(delta):
	
	var scaled_delta = delta / Engine.time_scale if bullet_time.active else delta
	
	_apply_rotation(scaled_delta)
	
	var vertical = velocity.y# + (delta * gravity)
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	var new_velocity = direction * speed
	var factor
	
	if new_velocity.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	if factor > 0:
		velocity = horizontal.linear_interpolate(new_velocity, factor * scaled_delta)
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
	
	collisions = []
	
	for index in range(owner.get_slide_count()):
		collisions.append(owner.get_slide_collision(index))
	
#	if collisions.size():
#		prints(' ')
	
#	for slide in collisions:
#		if slide.on_wall:
#			prints(OS.get_system_time_msecs())
	
	emit_signal('move_and_slide', delta)
