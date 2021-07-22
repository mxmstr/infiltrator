extends Node

export var climb_max_height_mult = 3
export var climb_find_range = 0.5
export var climb_forward_amount = 0.4

var climbing = false
var climb_collision_mask = 1024
var climb_steps = 50
var climb_height

var x_progress = 0
var y_progress = 0

var x_target
var y_target
var x_drag
var y_drag

onready var collision = $'../Collision' if has_node('../Collision') else null


func _get_climb_height_mult():
	
	return climb_height / (collision.shape.extents.y * climb_max_height_mult) if climb_height != null else 0


func _has_targets():
	
	return not (null in [x_target, y_target])


func _create_x_target(position):
	
	x_target = Meta.AddActor('Empty', position)


func _create_y_target(position):
	
	y_target = Meta.AddActor('Empty', position)


func _create_x_drag():
	
	var data = {
		'from': x_target.get_path(),
		'to': owner.get_path(),
		'relative': true,
		'power': 0.0
	}
	
	x_drag = LinkHub._create('Drag', data)


func _create_y_drag():
	
	var data = {
		'from': y_target.get_path(),
		'to': owner.get_path(),
		'relative': true,
		'power': 0.0
	}
	
	y_drag = LinkHub._create('Drag', data)


func _destroy_x_target():
	
	if x_target != null:
		
		x_target.queue_free()
		x_target = null


func _destroy_y_target():
	
	if y_target != null:
		
		y_target.queue_free()
		y_target = null


func _destroy_x_drag():
	
	if x_drag != null:
		
		x_drag._on_exit()
		x_drag = null


func _destroy_y_drag():
	
	if y_drag != null:
		
		y_drag._on_exit()
		y_drag = null


func _start_climbing():
	
	climbing = true


func _stop_climbing():
	
	climbing = false


func _test_for_wall(origin, cast_to):

	var ray = RayCast.new()
	ray.collision_mask = climb_collision_mask
	ray.add_exception(owner)
	owner.add_child(ray)
	
	ray.global_transform.origin = origin
	ray.cast_to = cast_to
	ray.force_raycast_update()
	
	var collider = ray.get_collider()
	var point = ray.get_collision_point()
	
	ray.free()
	
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
					
					x_progress = 0
					y_progress = 0
					
					_create_x_target(current_collision_point + climb_forward_offset)
					_create_y_target(Vector3(origin.x, current_collision_point.y, origin.z))
					
					return
		
		last_climb_height = climb_height


func _process(delta):
	
	if climbing:
		
		if x_drag != null:
			x_drag.power = x_progress
		
		if y_drag != null:
			y_drag.power = y_progress
	
