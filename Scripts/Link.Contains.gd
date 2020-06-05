extends 'res://Scripts/Link.gd'

export(String) var container

var container_node


func _find_free_container():
	
	for child in from_node.get_children():
		
		if child.get_script() != null:
		
			var script_name = child.get_script().get_path().get_file()
			
			if script_name == 'Prop.Container.gd' and child._add_item(to_node):
				
				container = child.name
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
			(item_bone_name == '' or item_bone_name == bone_name)
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
			(item_bone_name == '' or item_bone_name == bone_name)
			) else Vector3()
	
	return Vector3()


func _move_item():
	
	var item_position_offset = _get_item_position_offset(to_node)
	var item_rotation_offset = _get_item_rotation_offset(to_node)
	
	var new_transform = container_node.root.global_transform.translated(item_position_offset)
	
	new_transform.basis = container_node.root.global_transform.basis
	new_transform.basis = new_transform.global_transform.basis.rotated(new_transform.global_transform.basis.x, item_rotation_offset.x)
	new_transform.basis = new_transform.global_transform.basis.rotated(new_transform.global_transform.basis.y, item_rotation_offset.y)
	new_transform.basis = new_transform.global_transform.basis.rotated(new_transform.global_transform.basis.z, item_rotation_offset.z)
	
	Meta.StimulateActor(to_node, 'Contain', from_node, new_transform.origin, new_transform.basis.get_euler())


func _ready():
	
	if not _find_free_container():
		queue_free()


func _process(delta):
	
	var container_node = from_node.get_node(container)
	
	if not container_node._has_item(to_node):
		queue_free()
	
	_move_item()


func _exit_tree():
	
	var container_node = from_node.get_node(container)
	
	container_node._remove_item(to_node) if container_node != null else null
	
	
	var last_transform = item.global_transform.origin
	var last_rotation = item.rotation

	item.visible = true
	
	if item.has_node('Collision'):
		item.get_node('Collision').disabled = false

#		if item is RigidBody:
#
#			var item_name = item.name
#			var new_item = load(item.filename).instance()
#
#			$'/root/Mission/Actors'.add_child(new_item)
#			item.name = item_name + '_'
#
#			new_item.name = item_name
#			new_item.global_transform.origin = last_transform
#			new_item.rotation = last_rotation
#
#			if new_item.has_node('Movement'):
#				new_item.get_node('Movement')._set_speed(release_speed)
#				new_item.get_node('Movement')._set_direction(release_direction)
#
#			item.queue_free()
#
#		else:
	
	if item.has_node('Movement'):
		item.get_node('Movement')._set_speed(release_speed)
		item.get_node('Movement')._set_direction(release_direction)