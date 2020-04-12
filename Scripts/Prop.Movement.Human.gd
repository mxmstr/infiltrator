extends Node

enum state {
	CRAWLING,
	CROUCHING,
	WALKING,
	RUNNING
}

enum lean {
	DEFAULT,
	LEFT,
	RIGHT
}

export(state) var current_state setget _set_state
export(lean) var current_lean = lean.DEFAULT

export var gravity = -9.8
export var max_speed = 2.75
export var walk_mult = 0.3
export var crouch_mult = 0.15
export var crawl_mult = 0.1

export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

export var climb_max_height_mult = 4
export var climb_find_range = 0.5
export var climb_forward_amount = 0.4

export var collision_height_mult = 1.0

var enable_rotation = true
var enable_movement = true

var speed = 0.0
var direction = Vector3()
var velocity = Vector3()

var climbing = false
var climb_collision_mask = 1024
var climb_steps = 50
var climb_height
var climb_start = null
var climb_target = null
var climb_x_progress = 0
var climb_y_progress = 0

onready var collision = $'../Collision'
#onready var ik_righthand = $'../Model'.get_child(0).get_node('RightHandIK/Target')


func _get_climb_height_mult():
	
	return climb_height / (collision.shape.extents.y * climb_max_height_mult) if climb_height != null else 0


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_leftright_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _rotate(delta):
	
	if not enable_rotation:
		return
	
	owner.rotation.y += delta


func _set_state(new_state):
	
	if not enable_movement:
		return
	
	current_state = new_state


func _set_speed(new_speed):
	
	if not enable_movement:
		return
	
	match current_state:
		
		state.WALKING:
			
			speed = new_speed * max_speed * walk_mult
		
		state.CROUCHING:
			
			speed = new_speed * max_speed * crouch_mult
		
		state.RUNNING:
			
			speed = new_speed * max_speed
		
		state.CRAWLING:
			
			speed = new_speed * max_speed * crawl_mult


func _set_direction(new_direction):
	
	if not enable_movement:
		return
	
	direction = new_direction


func _set_horizontal_velocity(horizontal):
	
	horizontal = owner.global_transform.basis.xform(horizontal)
	velocity = Vector3(horizontal.x, velocity.y, horizontal.z)


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _align_to_camera():
	
	var target = owner.global_transform.origin + $'../CameraRig/Camera'.global_transform.basis.z#.inverse()
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))


func _test_for_wall(origin, cast_to):

	var ray = RayCast.new()
	ray.collision_mask = climb_collision_mask
	ray.add_exception(owner)
	add_child(ray)
	
	ray.global_transform.origin = origin
	ray.cast_to = cast_to
	ray.force_raycast_update()
	
	var collider = ray.get_collider()
	var point = ray.get_collision_point()
	
	ray.free()
	
	#Inf.add_waypoint(point) if point != null else null
	
	return point if collider != null else null


func _find_climb_target():
	
	if climbing:
		return
	
	
	var in_range = false
	var collision_width = collision.shape.extents.x
	var collision_height = collision.shape.extents.y
	var origin = owner.global_transform.origin
	var basis = owner.global_transform.basis
	
	
	var last_climb_height
	var offsets = range(climb_steps)
	offsets.invert()
	
	for i in offsets:
		
		climb_height = collision_height * climb_max_height_mult * ((i + 1) / float(climb_steps))
		
		if last_climb_height != null:
			
			var height_offset = Vector3(0, climb_height, 0)
			var last_height_offset = Vector3(0, last_climb_height, 0)
			var climb_forward_offset = Vector3(0, 0, climb_forward_amount) * basis.z
			
			if _test_for_wall(origin, last_height_offset) != null:
				break
			
			
			var last_collision_point = _test_for_wall(origin + last_height_offset, Vector3(0, 0, climb_find_range))
			var current_collision_point = _test_for_wall(origin + height_offset, Vector3(0, 0, climb_find_range))
			var edge_found = last_collision_point == null and current_collision_point != null
			
			if edge_found:
				
				current_collision_point.y = (origin + last_height_offset).y
				
				var blocked = false
				
				for point in [_test_for_wall(current_collision_point, Vector3(0, 0, climb_forward_amount)),
					_test_for_wall(current_collision_point, Vector3(collision_width * 0.5, 0, climb_forward_amount)),
					_test_for_wall(current_collision_point, Vector3(collision_width * -0.5, 0, climb_forward_amount)),
					_test_for_wall(current_collision_point + climb_forward_offset, Vector3(0, collision_height, 0))]:
					
					if point != null:
						blocked = true
						break
				
				if not blocked:
					
					climbing = true
					climb_start = origin
					climb_target = current_collision_point + climb_forward_offset
					
					climb_x_progress = 0
					climb_y_progress = 0
					
					return
		
		last_climb_height = climb_height
	
	climbing = false
	climb_start = null
	climb_target = null


func _resize_collision():
	
	collision.shape.extents.y = collision_height_mult
	collision.translation.y = collision_height_mult


func _ready():
	
	current_state = state.WALKING


func _physics_process(delta):
	
	_resize_collision()
	
	
	var vertical = velocity.y + (delta * gravity)
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	
	if climbing:
		
		#if climb_target != null:
		
		var new_x_pos = climb_start.linear_interpolate(climb_target, climb_x_progress)
		var new_y_pos = climb_start.linear_interpolate(climb_target, climb_y_progress)
		
		owner.global_transform.origin = Vector3(new_x_pos.x, new_y_pos.y, new_x_pos.z)
		
		horizontal = Vector3()
		vertical = 0
		direction = Vector3()
	
	
	var new_velocity = owner.global_transform.basis.xform(direction) * speed
	var factor
	
	if new_velocity.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	velocity = horizontal.linear_interpolate(new_velocity, factor * delta)
	velocity.y = vertical
	
	velocity = owner.move_and_slide(velocity, Vector3(0, 1, 0))
