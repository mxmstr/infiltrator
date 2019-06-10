extends Node

enum state {
	DEFAULT,
	CLIMBING
}

export(state) var current_state
export var gravity = -9.8
export var max_speed = 5
export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30
export var climb_speed = 100.0

var direction = Vector3()
var velocity = Vector3()
var climb_height_mult = 2
var climb_steps = 50
var climb_target = Vector3()
var climb_progress = 0


func _set_state(new_state):
	
	#print(new_state)
	current_state = state[new_state]


func _get_climb_target():
	
	if current_state == state.CLIMBING:
		return true
	
	var in_range = false
	var height = climb_height_mult * get_parent().get_node('CollisionShape').shape.height
	
	var ray = RayCast.new()
	ray.add_exception(get_parent())
	add_child(ray)
	
	var last_point
	var offsets = range(climb_steps)
	offsets.invert()
	
	#print('asdf')
	for i in offsets:
		
		var offset = Vector3(0, height * ((i + 1) / float(climb_steps)), 0)
		var origin = get_parent().global_transform.origin + offset
		
		ray.global_transform.origin = origin
		ray.cast_to = Vector3(0, 0, -1.0)
		ray.force_raycast_update()
		
		#print(ray.get_collider())
		
		if ray.get_collider() == null:
			in_range = true
		elif in_range:
			#print('target')
			#if last_point == null:
			climb_target = ray.get_collision_point()
#			else:
#				climb_target = last_point
			
			climb_progress = 0
			#print(climb_target)
			return true
		
		last_point = ray.get_collision_point()
	
	ray.queue_free()
	
	return false


func _physics_process(delta):
	
	var current_pos = get_parent().global_transform.origin
	
	
	velocity.y += delta * gravity
	
	var hvelocity = velocity
	hvelocity.y = 0
	
	
	var target = Vector3()
	
	match current_state:
		
		state.DEFAULT:
			
			target = direction * max_speed
		
		state.CLIMBING:
			
			#climb_target.x = current_pos.x
			#climb_target.z = current_pos.z
			
			get_parent().global_transform.origin = current_pos.linear_interpolate(climb_target, climb_progress)# * climb_speed
			
			velocity.x = 0
			velocity.z = 0
	
	var factor
	
	if direction.dot(hvelocity) > 0:
		factor = accel
	else:
		factor = deaccel
	
	hvelocity = hvelocity.linear_interpolate(target, factor * delta)
	
	velocity.x = hvelocity.x
	#velocity.y = hvelocity.y
	velocity.z = hvelocity.z
	
	velocity = get_parent().move_and_slide(velocity, Vector3(0, 1, 0))