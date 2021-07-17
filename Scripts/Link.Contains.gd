extends 'res://Scripts/Link.gd'

export(String) var container

var container_node


func _is_container(prop):
	
	if prop.get_script() != null:
		
		var script_name = prop.get_script().get_path().get_file()
		
		return script_name == 'Prop.Container.gd'
	
	return false


func _find_free_container():
	
	for prop in from_node.get_children():
		
		if _is_container(prop):
			
			for item_tag in prop.required_tags.split(' '):
				if not item_tag in to_node.tags:
					continue
			
			if len(prop.items) >= prop.max_quantity:
				continue
				
			to_node.visible = not prop.invisible
			
			if to_node.has_node('Collision'):
				to_node.get_node('Collision').disabled = true
			
			prop._add_item(to_node)
			
			container = prop.name
			container_node = from_node.get_node(container)
			
			return true
	
	return false


func _get_item_position_offset(item):
	
	if item._has_tag('Offset-position'):
		
		var item_data = item._get_tag('Offset-position')
		
		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2])) if (
			(item_parent_name == '' or container_node.root.get_parent().name == item_parent_name) and \
			(item_bone_name == '' or item_bone_name == container_node.bone_name)
			) else Vector3()
	
	return Vector3()


func _get_item_rotation_offset(item):
	
	if item._has_tag('Offset-rotation'):
		
		var item_data = item._get_tag('Offset-rotation')
		
		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		return Vector3(deg2rad(float(item_offset[0])), deg2rad(float(item_offset[1])), deg2rad(float(item_offset[2]))) if (
			(item_parent_name == '' or container_node.root.get_parent().name == item_parent_name) and \
			(item_bone_name == '' or item_bone_name == container_node.bone_name)
			) else Vector3()
	
	return Vector3()


func _move_item():
	
	var item_position_offset = _get_item_position_offset(to_node)
	var item_rotation_offset = _get_item_rotation_offset(to_node)
	
	var new_transform = container_node.root.global_transform.translated(item_position_offset)
	
	new_transform.basis = container_node.root.global_transform.basis
	new_transform.basis = new_transform.basis.rotated(new_transform.basis.x, item_rotation_offset.x)
	new_transform.basis = new_transform.basis.rotated(new_transform.basis.y, item_rotation_offset.y)
	new_transform.basis = new_transform.basis.rotated(new_transform.basis.z, item_rotation_offset.z)
	
	to_node.get_node('Movement')._teleport(new_transform.origin, new_transform.basis.get_euler()) if to_node.has_node('Movement') else null


func _ready():
	
	if is_queued_for_deletion():
		return
	
	if not _find_free_container():
		queue_free()


func _process(delta):
	
	if not container_node._has_item(to_node):
		queue_free()
	
	_move_item()


func _exit_tree():
	
	container_node._remove_item(to_node) if container_node != null else null
	
	
	to_node.visible = true
	
	if to_node.has_node('Collision'):
		to_node.get_node('Collision').disabled = false
	
	to_node.get_node('Movement')._set_speed(container_node.release_speed) if to_node.has_node('Movement') else null
	to_node.get_node('Movement')._set_direction(container_node.release_direction) if to_node.has_node('Movement') else null
	
#	if to_node.get('sleeping') != null:
#		to_node.apply_impulse(Vector3(), Vector3(0, -10, 0))
