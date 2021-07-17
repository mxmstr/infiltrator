tool
extends Spatial

const default_cone = { 'y_angle': 90.0, 'x_angle': 90.0, 'range': 10.0, 'acuity': 1.0 }

export(String) var joint
export(Array, Dictionary) var cones setget _set_cones


func _set_cones(new_cones):
	
	if Engine.editor_hint:
		
		if new_cones.size() > cones.size():
			new_cones[-1] = default_cone.duplicate()
	
	cones = new_cones


func _is_visible(event, intensity):
	
	for cone in cones:
		
		if cone.range < owner.distance_to(event):
			continue
		
		if cone.y_angle < owner.global_transform.basis.z.angle_to(owner.direction_to(event)):
			continue
		
		return true
	
	return false
