extends 'res://Scripts/Link.gd'

export(String) var container

var root
var container_node
var human = false
var restore_collisions = true
var merge = false
var from_behavior
var movement
var collision
var reception
var item_position_offset
var item_rotation_offset


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _merge_with_existing(other_container, other_item):
	
	for prop in to_node.get_children():
		
		if _is_container(prop):
			
			var items
			
			if prop.factory_mode:
				
				items = prop.items
				var new_container = other_container
				
				for item in items:
					
					if not new_container._add_item(item):
						
						var other_item_clone = Meta.AddActor(other_item.system_path)
						other_item_clone.get_node(prop.name)._add_item(item)
						Meta.CreateLink(from_node, other_item_clone, 'Contains', { 'container': '', 'merge': false }).is_queued_for_deletion()
						
						new_container = other_item_clone.get_node(prop.name)
						new_container._add_item(item)
				
				
			else:
				
				items = Meta.DestroyLink(to_node, null, 'Contains', { 'container': prop.name })
				
				for item in items:
					if Meta.CreateLink(other_item, item, 'Contains', { 'container': '' }).is_queued_for_deletion():
						Meta.CreateLink(from_node, item, 'Contains', { 'container': '' })
	
	
	to_node.queue_free()


func _try_container(node):
	
	for item_tag in node.required_tags_dict.keys():
		if item_tag.length() and not item_tag in to_node.tags_dict.keys():
			return false
	
	
	if merge and to_node._has_tag('MergeWithSimilar'):
		
		for item in node.items:
			
			if item.base_name == to_node.base_name:
				
				_merge_with_existing(node, item)
				queue_free()
				
				return true
	
	
	if node.max_quantity > 0 and len(node.items) >= node.max_quantity:
		return false
	
	to_node.visible = not node.invisible
	
	if collision:
		collision.disabled = true
	
	node._add_item(to_node)
	
	if from_behavior.get_script().has_script_signal('pre_advance'):
		
		from_behavior.connect('pre_advance', self, '_move_item')
		human = true
	
	return true


func _find_free_container():
	
	for prop in from_node.get_children():
		
		if _is_container(prop) and _try_container(prop):
			
			container = prop.name
			container_node = prop
			
			return true
	
	return false


func _get_item_position_offset(item):
	
	if item._has_tag('Offset-position'):

		var item_data = item._get_tag('Offset-position')

		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')

		return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2])) if (
			(item_parent_name == '' or (container_node.root and container_node.root.get_parent().name == item_parent_name)) and \
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
			(item_parent_name == '' or (container_node.root and container_node.root.get_parent().name == item_parent_name)) and \
			(item_bone_name == '' or item_bone_name == container_node.bone_name)
			) else Vector3()
	
	return Vector3()


func _move_item():
	
	if is_queued_for_deletion() or _is_invalid():
		return
	
	if movement and weakref(movement).get_ref() and not movement.is_queued_for_deletion():
		
		var new_transform = root.global_transform
		movement._teleport(new_transform.origin, new_transform.basis)


func _ready():
	
	if is_queued_for_deletion():
		return
	
	from_behavior = from_node.get_node_or_null('Behavior')
	movement = to_node.get_node_or_null('Movement')
	collision = to_node.get_node_or_null('Collision')
	reception = to_node.get_node_or_null('Reception')
	
	if container == '' or container == null:
		
		if not _find_free_container():
			
			queue_free()
			return
		
	else:
		
		if _try_container(from_node.get_node(container)):
			
			if to_node.is_queued_for_deletion():
				_destroy()
				return
			
			container_node = from_node.get_node(container)
		else:
			queue_free()
			return
	
	item_position_offset = _get_item_position_offset(to_node)
	item_rotation_offset = _get_item_rotation_offset(to_node)
	
	root = Spatial.new()
	container_node.root.add_child(root)
	root.translation = item_position_offset
	root.rotation = item_rotation_offset


func _process(delta):
	
	if is_queued_for_deletion() or _is_invalid():
		return
	
	if not container_node._has_item(to_node):
		queue_free()
	
	if not human:
		_move_item()


func _restore_collision():
	
	if weakref(to_node).get_ref() and not to_node.is_queued_for_deletion():
	
		to_node.visible = true
		
		if collision:
			collision.disabled = false
		
		
		if container_node and weakref(container_node).get_ref():
			
			container_node._apply_launch_attributes(to_node)
			

func _destroy():
	
	if container_node and weakref(container_node).get_ref():
		container_node._remove_item(to_node)
	
	if restore_collisions:
		_restore_collision()
	
	if root and weakref(root).get_ref():
		root.queue_free()
	
	._destroy()
