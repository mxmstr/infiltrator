extends 'res://Scripts/Prop.Movement.gd'

const gravity = 9.8
const max_slides = 4
const accel = 3.0
const deaccel = 6.0
const angular_accel = 0.02#0.05
const angular_deaccel = 9.0
const angular_vertical_speed_mult = 0.5

const SPEED_DEFAULT: float = 7.0
const SPEED_ON_STAIRS: float = 5.0
const ACCEL_DEFAULT: float = 7.0
const ACCEL_AIR: float = 1.0
const WALL_MARGIN: float = 0.001
const STEP_HEIGHT_DEFAULT: Vector3 = Vector3(0, 0.5, 0)
const STEP_MAX_SLOPE_DEGREE: float = 5.0
const STEP_CHECK_COUNT: int = 1

var on_wall_count = 0
var is_step: bool = false
var step_check = false
var step_check_height: Vector3 = STEP_HEIGHT_DEFAULT / STEP_CHECK_COUNT
var gravity_vec: Vector3 = Vector3.ZERO
var movement: Vector3 = Vector3.ZERO

var gravity_scale = 1.0
var angular_velocity_x_pos = 0.0
var angular_velocity_x_neg = 0.0
var angular_velocity_y_pos = 0.0
var angular_velocity_y_neg = 0.0
var rotate_x_camera = false
var rotate_y_camera = true
var snap = Vector3()
var factorx = angular_deaccel
var factory = angular_deaccel
var root_motion_use_model = false

onready var model = get_node_or_null('../Model')
onready var behavior = get_node_or_null('../Behavior')
onready var camera_rig = get_node_or_null('../CameraRig')
onready var bullet_time = get_node_or_null('../BulletTime')

signal move_and_slide


func _get_collisions():
	
	return collisions


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_sidestep_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _set_vertical_velocity(vertical):
	
	gravity_vec.y = vertical


func _add_vertical_velocity(vertical):
	
	gravity_vec.y += vertical


func _apply_root_transform(root_transform):
	
	if root_transform == Transform():
		return
	
	#root_transform.origin /= get_process_delta_time()
	
	if root_motion_use_model:
		
		var transform_offset = owner.global_transform
		transform_offset.basis = model.global_transform.basis
		transform_offset *= root_transform
		transform_offset.basis = owner.global_transform.basis
		owner.global_transform = transform_offset
	
	else:
		
		owner.global_transform *= root_transform


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


func _test_movement(new_velocity):
	
	return owner.move_and_collide(new_velocity, true, true, true)


func _apply_rotation(delta):
	
	var angular_velocity = angular_direction * delta
	
	if rotate_x_camera:
		camera_rig._rotate_camera(angular_velocity.y, angular_velocity.x)
	else:
		owner.rotation.y += angular_velocity.x
		camera_rig._rotate_camera(angular_velocity.y, 0.0)


func _physics_process(delta):
	
	var scaled_delta = delta / Engine.time_scale if bullet_time.active else delta
	
	_apply_rotation(scaled_delta)
	
	is_step = false

	#get keyboard input
#	direction = Vector3.ZERO
#	var h_rot: float = owner.global_transform.basis.get_euler().y
#	var f_input: float = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
#	var h_input: float = Input.get_action_strength("Right") - Input.get_action_strength("Left")
#	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if owner.is_on_floor():
		
		if gravity_vec.y > 0:
			#factor = ACCEL_AIR
			snap = Vector3.ZERO
		else:
			snap = -owner.get_floor_normal()
			#factor = ACCEL_DEFAULT
			gravity_vec = Vector3.ZERO
		
	else:
		snap = Vector3.DOWN
		#factor = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
	
	
	var new_velocity = direction * speed
	var factor

	if new_velocity.dot(velocity) > 0:
		factor = accel
	else:
		factor = deaccel

	if factor > 0:
		velocity = velocity.linear_interpolate(new_velocity, factor * scaled_delta)
	else:
		velocity = new_velocity
	
#	if velocity.y > 0:# and owner.is_on_floor():
#		snap = Vector3.ZERO
#		gravity_vec = Vector3.UP * velocity.y

	if step_check and gravity_vec.y >= 0:
		
		for i in range(STEP_CHECK_COUNT):
			var test_motion_result: PhysicsTestMotionResult = PhysicsTestMotionResult.new()

			var step_height: Vector3 = STEP_HEIGHT_DEFAULT - i * step_check_height
			var transform3d: Transform = owner.global_transform
			var motion: Vector3 = step_height
			var is_player_collided: bool = PhysicsServer.body_test_motion(owner.get_rid(), transform3d, motion, false, test_motion_result)
#
			#prints('is_player_collided 0', is_player_collided, test_motion_result.collision_normal.y < 0, str(randi()))
			if test_motion_result.collision_normal.y < 0:
				continue

			if not is_player_collided:
				transform3d.origin += step_height
				motion = velocity * delta
				is_player_collided = PhysicsServer.body_test_motion(owner.get_rid(), transform3d, motion, false, test_motion_result)

				#prints('is_player_collided 1', is_player_collided, str(randi()))
				if not is_player_collided:
					transform3d.origin += motion
					motion = -step_height
					is_player_collided = PhysicsServer.body_test_motion(owner.get_rid(), transform3d, motion, false, test_motion_result)
					#prints('is_player_collided 2', is_player_collided, str(randi()))
					if is_player_collided:
						#prints('is_player_collided 2', test_motion_result.collision_normal.angle_to(Vector3.UP), str(randi()))
						if test_motion_result.collision_normal.angle_to(Vector3.UP) <= deg2rad(STEP_MAX_SLOPE_DEGREE):
							#head_offset = -test_motion_result.motion_remainder
							is_step = true
							#prints('is step 1 ' + str(randi()))
							owner.global_transform.origin += -test_motion_result.motion_remainder
							break
				else:
					var wall_collision_normal: Vector3 = test_motion_result.collision_normal

					transform3d.origin += test_motion_result.collision_normal * WALL_MARGIN
					motion = (velocity * delta).slide(wall_collision_normal)
					is_player_collided = PhysicsServer.body_test_motion(owner.get_rid(), transform3d, motion, false, test_motion_result)
					#prints('is_player_collided 3', is_player_collided, str(randi()))
					if not is_player_collided:
						transform3d.origin += motion
						motion = -step_height
						is_player_collided = PhysicsServer.body_test_motion(owner.get_rid(), transform3d, motion, false, test_motion_result)
						#prints('is_player_collided 4', is_player_collided, str(randi()))
						if is_player_collided:
							if test_motion_result.collision_normal.angle_to(Vector3.UP) <= deg2rad(STEP_MAX_SLOPE_DEGREE):
								#head_offset = -test_motion_result.motion_remainder
								is_step = true
								#prints('is step 2 ' + str(randi()))
								owner.global_transform.origin += -test_motion_result.motion_remainder
								break
	
	movement = velocity + gravity_vec
	
	_apply_root_transform(behavior.get_root_motion_transform())
	
# warning-ignore:return_value_discarded
	owner.move_and_slide_with_snap(movement, snap, Vector3.UP, false, 2, deg2rad(46), false)
	
	collisions = []
	var new_on_wall_count = 0

	for index in range(owner.get_slide_count()):
		
		var slide = owner.get_slide_collision(index)
		
		if slide.on_wall:
			new_on_wall_count += 1
		
		collisions.append(slide)
	
	#prints(owner.get_slide_count())
	
#	if new_on_wall_count != on_wall_count:
#		prints(on_wall_count, new_on_wall_count)
	
	step_check = new_on_wall_count != on_wall_count
	on_wall_count = new_on_wall_count

	emit_signal('move_and_slide', delta)
