extends Node

enum state {
	DEFAULT,
	WALKING,
	CLIMBING,
	CROUCHING,
	RUNNING,
	CRAWLING
}

export(state) var current_state = state.WALKING

export var gravity = -9.8
export var max_speed = 2.75
export var walk_mult = 0.3
export var crouch_mult = 0.2
export var crawl_mult = 0.1

export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

export var climb_speed = 100.0
export var climb_height_mult = 2
export var climb_range = 0.5
export var climb_horizontal_distance = 0.25

var direction = Vector3()
var velocity = Vector3()
var climb_collision_mask = 1024
var climb_steps = 50
var climb_target = null
var climb_x_progress = 0
var climb_y_progress = 0

onready var collision = $'../Collision'
onready var camera = $'../Perspective/Container/Viewport/CameraRig/Camera'
#onready var ik_righthand = $'../Model'.get_child(0).get_node('RightHandIK/Target')


func _ready():
	
	pass


func _set_state(new_state):
	
	current_state = state[new_state]


func _get_state():
	
	return current_state


func _set_direction_local(new_direction):
	
	new_direction = get_parent().global_transform.basis.xform(new_direction)
	
	direction = new_direction


func _set_y_velocity(new_velocity):
	
	velocity.y = new_velocity


func _has_climb_target():
	
	return climb_target != null


func _find_climb_target():
	
	if current_state == state.CLIMBING:
		return true
	
	
	var in_range = false
	var height = collision.shape.extents.y
	
	var ray_to_target = RayCast.new()
	ray_to_target.collision_mask = climb_collision_mask
	ray_to_target.add_exception(get_parent())
	add_child(ray_to_target)
	
	var ray_to_self = RayCast.new()
	ray_to_target.collision_mask = climb_collision_mask
	ray_to_self.add_exception(get_parent())
	add_child(ray_to_self)
	
	
	var last_point
	var offsets = range(climb_steps)
	offsets.invert()
	
	for i in offsets:
		
		var climb_height = height * climb_height_mult * ((i + 1) / float(climb_steps))
		var offset = Vector3(0, climb_height, 0)
		var origin = get_parent().global_transform.origin + offset
		
		ray_to_target.global_transform.origin = origin
		ray_to_target.cast_to = Vector3(0, 0, climb_range)
		ray_to_target.force_raycast_update()
		
		ray_to_self.global_transform.origin = origin
		ray_to_self.cast_to = origin.direction_to(get_parent().global_transform.origin)
		ray_to_self.force_raycast_update()
		
		
		var wall_found = ray_to_target.get_collider() == null
		var climb_blocked = ray_to_self.get_collider() != null
		
		if climb_height < height or not climb_blocked:
			
			if wall_found:
				in_range = true
				
			elif in_range:
				climb_target = ray_to_target.get_collision_point()
				climb_target += origin.direction_to(climb_target) * climb_horizontal_distance
				
				#ik_righthand.global_transform.origin = climb_target
				
				climb_x_progress = 0
				climb_y_progress = 0
				
				return
		
		last_point = ray_to_target.get_collision_point()
	
	ray_to_target.queue_free()
	ray_to_self.queue_free()
	
	climb_target = null


func _physics_process(delta):
	
	var current_pos = get_parent().global_transform.origin
	var vertical = velocity.y + (delta * gravity)
	var horizontal = Vector3(velocity.x, 0, velocity.z)
	var target = Vector3()
	
	match current_state:
		
		state.DEFAULT:
			
#			collision.translation = Vector3(0, 0.75, 0)
#			collision.shape.extents.y = 0.75
#			camera.offset = Vector3(0, 1.70, 0)
			
			target = direction
		
		state.WALKING:
			
#			collision.translation = Vector3(0, 0.75, 0)
#			collision.shape.extents.y = 0.75
#			camera.offset = Vector3(0, 1.70, 0)
			
			target = direction * max_speed * walk_mult
		
		state.CLIMBING:
			
#			collision.translation = Vector3(0, 0.75, 0)
#			collision.shape.extents.y = 0.75
#			camera.offset = Vector3(0, 1.70, 0)
			
			var new_x_pos = current_pos.linear_interpolate(climb_target, climb_x_progress)
			var new_y_pos = current_pos.linear_interpolate(climb_target, climb_y_progress)
			
			get_parent().global_transform.origin = Vector3(new_x_pos.x, new_y_pos.y, new_x_pos.z)
			
			velocity.x = 0
			velocity.z = 0
		
		state.CROUCHING:
			
#			collision.translation = Vector3(0, 0.3, 0)
#			collision.shape.extents.y = 0.3
#			camera.offset = Vector3(0, 0.70, 0)
			
			target = direction * max_speed * crouch_mult
		
		state.RUNNING:
			
#			collision.translation = Vector3(0, 0.75, 0)
#			collision.shape.extents.y = 0.75
#			camera.offset = Vector3(0, 1.70, 0)
			
			target = direction * max_speed
		
		state.CRAWLING:
			
#			collision.translation = Vector3(0, 0.1, 0)
#			collision.shape.extents.y = 0.1
#			camera.offset = Vector3(0, 0.2, 0)
			
			target = direction * max_speed * crawl_mult
	
	
	var factor
	
	if direction.dot(horizontal) > 0:
		factor = accel
	else:
		factor = deaccel
	
	velocity = horizontal.linear_interpolate(target, factor * delta)
	velocity.y = vertical
	
	velocity = get_parent().move_and_slide(velocity, Vector3(0, 1, 0))
	
	#print(current_state)
