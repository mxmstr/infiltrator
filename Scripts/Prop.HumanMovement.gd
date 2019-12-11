extends Node

enum state {
	CRAWLING,
	CROUCHING,
	WALKING,
	RUNNING,
	CLIMBING
}

enum lean {
	DEFAULT,
	LEFT,
	RIGHT
}

export(state) var current_state = state.WALKING
export(lean) var current_lean = lean.DEFAULT

export var gravity = -9.8
export var max_speed = 2.75
export var walk_mult = 0.3
export var crouch_mult = 0.2
export var crawl_mult = 0.1

export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

export var climb_max_height_mult = 2
export var climb_find_range = 0.5
export var climb_forward_amount = 0.25

export var collision_height_mult = 1.0

var direction = Vector3()
var velocity = Vector3()
var climb_collision_mask = 1024
var climb_steps = 50
var climb_start = null
var climb_target = null
var climb_x_progress = 0
var climb_y_progress = 0

onready var collision = $'../Collision'
#onready var ik_righthand = $'../Model'.get_child(0).get_node('RightHandIK/Target')


func _ready():
	
	pass


func _get_forward_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).z


func _get_leftright_speed():
	
	return owner.global_transform.basis.xform_inv(velocity).x


func _set_direction(local_direction):
	
	direction = owner.global_transform.basis.xform(local_direction)
	
	match current_state:
		
		state.WALKING:
			
			direction *= max_speed * walk_mult
		
		state.CROUCHING:
			
			direction *= max_speed * crouch_mult
		
		state.RUNNING:
			
			direction *= max_speed
		
		state.CRAWLING:
			
			direction *= max_speed * crawl_mult


func _set_horizontal_velocity(horizontal):
	
	horizontal = owner.global_transform.basis.xform(horizontal)
	velocity = Vector3(horizontal.x, velocity.y, horizontal.z)


func _set_vertical_velocity(vertical):
	
	velocity.y = vertical


func _find_climb_target():
	
	if current_state == state.CLIMBING:
		return
	
	
	var in_range = false
	var height = collision.shape.extents.y
	var owner_origin = owner.global_transform.origin
	
	var ray_to_target = RayCast.new()
	ray_to_target.collision_mask = climb_collision_mask
	ray_to_target.add_exception(owner)
	add_child(ray_to_target)
	
	var ray_to_self = RayCast.new()
	ray_to_target.collision_mask = climb_collision_mask
	ray_to_self.add_exception(owner)
	add_child(ray_to_self)
	
	
	var last_point = owner_origin + Vector3(0, height * climb_max_height_mult, 0)
	var offsets = range(climb_steps)
	offsets.invert()
	
	for i in offsets:
		
		var climb_height = height * climb_max_height_mult * ((i + 1) / float(climb_steps))
		var offset = Vector3(0, climb_height, 0)
		var origin = owner_origin + offset
		
		ray_to_target.global_transform.origin = origin
		ray_to_target.cast_to = Vector3(0, 0, climb_find_range)
		ray_to_target.force_raycast_update()
		
		ray_to_self.global_transform.origin = origin
		ray_to_self.cast_to = origin.direction_to(owner_origin)
		ray_to_self.force_raycast_update()
		
		
		var wall_found = ray_to_target.get_collider() != null
		var climb_blocked = ray_to_self.get_collider() != null
		
		if climb_height < height or not climb_blocked:
			
#			if wall_found:
#				in_range = true
#
#			elif in_range:
			if wall_found:
				climb_start = owner_origin
				
				climb_target = ray_to_target.get_collision_point()
				climb_target += origin.direction_to(climb_target) * climb_forward_amount
				climb_target.y = last_point.y
				
				#ik_righthand.global_transform.origin = climb_target
				
				climb_x_progress = 0
				climb_y_progress = 0
				
				return
		
		last_point = origin#ray_to_target.get_collision_point()
	
	ray_to_target.queue_free()
	ray_to_self.queue_free()
	
	climb_start = null
	climb_target = null


func _resize_collision():
	
	collision.shape.extents.y = collision_height_mult
	collision.translation.y = collision_height_mult


func _physics_process(delta):
	
	_resize_collision()
	
	
	var vertical = velocity.y + (delta * gravity)
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	
	
	if current_state == state.CLIMBING:
		
		var current_pos = owner.global_transform.origin
		var new_x_pos = climb_start.linear_interpolate(climb_target, climb_x_progress)
		var new_y_pos = climb_start.linear_interpolate(climb_target, climb_y_progress)
		
		owner.global_transform.origin = Vector3(new_x_pos.x, new_y_pos.y, new_x_pos.z)
		
		horizontal = Vector3()
		vertical = 0
		direction = Vector3()
	
	
	var factor
	
	if direction.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	
	velocity = horizontal.linear_interpolate(direction, factor * delta)
	velocity.y = vertical
	
	velocity = get_parent().move_and_slide(velocity, Vector3(0, 1, 0))
