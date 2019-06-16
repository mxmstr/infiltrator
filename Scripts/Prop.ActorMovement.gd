extends Node

enum state {
	DEFAULT,
	CLIMBING,
	CROUCHING,
	RUNNING,
	CRAWLING
}

export(state) var current_state

export var gravity = -9.8
export var max_speed = 4.5
export var walk_mult = 0.4
export var crouch_mult = 0.3
export var crawl_mult = 0.1

export var jump_speed = 7
export var accel = 2
export var deaccel = 4
export var max_slope_angle = 30

export var climb_speed = 100.0
export var climb_height_mult = 2
export var climb_range = 1.0

var direction = Vector3()
var velocity = Vector3()
var climb_steps = 50
var climb_target = Vector3()
var climb_progress = 0

onready var collision = $'../CollisionShape'
onready var camera = $'../PlayerControl/Viewport/Camera'


func _ready():
	
	pass


func _set_state(new_state):
	
	#print(new_state)
	current_state = state[new_state]


func _get_climb_target():
	
	if current_state == state.CLIMBING:
		return true
	
	
	var in_range = false
	var height = $'../CollisionShape'.shape.height
	
	var ray_to_target = RayCast.new()
	ray_to_target.add_exception(get_parent())
	add_child(ray_to_target)
	
	var ray_to_self = RayCast.new()
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
		ray_to_target.cast_to = Vector3(0, 0, -climb_range)
		ray_to_target.force_raycast_update()
		
		ray_to_self.global_transform.origin = origin
		ray_to_self.cast_to = origin.direction_to(get_parent().global_transform.origin + Vector3(0, 0.0, 0))
		ray_to_self.force_raycast_update()
		
		
		var wall_found = ray_to_target.get_collider() == null
		var climb_blocked = ray_to_self.get_collider() != null
		
		if climb_height < height or not climb_blocked:
			
			if wall_found:
				in_range = true
			elif in_range:
				#if last_point == null:
				climb_target = ray_to_target.get_collision_point()
	#			else:
	#				climb_target = last_point
				
				climb_progress = 0
				return true
		
		last_point = ray_to_target.get_collision_point()
	
	ray_to_target.queue_free()
	ray_to_self.queue_free()
	
	return false


func _physics_process(delta):
	
	var current_pos = get_parent().global_transform.origin
	
	
	velocity.y += delta * gravity
	
	var hvelocity = velocity
	hvelocity.y = 0
	
	
	var target = Vector3()
	
	match current_state:
		
		state.DEFAULT:
			
			$'../CollisionShape'.shape.height = 1
			camera.offset = Vector3(0, 1.75, 0)
			
			target = direction * max_speed * walk_mult
		
		state.CLIMBING:
			
			$'../CollisionShape'.shape.height = 1
			camera.offset = Vector3(0, 1.75, 0)
			
			get_parent().global_transform.origin = current_pos.linear_interpolate(climb_target, climb_progress)
			
			velocity.x = 0
			velocity.z = 0
		
		state.CROUCHING:
			
			$'../CollisionShape'.shape.height = 0.5
			camera.offset = Vector3(0, 0.75, 0)
			
			target = direction * max_speed * crouch_mult
		
		state.RUNNING:
			
			$'../CollisionShape'.shape.height = 1
			camera.offset = Vector3(0, 1.75, 0)
			
			target = direction * max_speed
		
		state.CRAWLING:
			
			$'../CollisionShape'.shape.height = 0.2
			camera.offset = Vector3(0, 0.2, 0)
			
			target = direction * max_speed * crawl_mult
	
	
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