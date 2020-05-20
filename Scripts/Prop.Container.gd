extends Node

export(NodePath) var path
export(String) var bone_name
export(Vector3) var position_offset
export(Vector3) var rotation_degrees_offset
export(float) var release_speed
export(Vector3) var release_direction
export(int) var max_quantity
export(bool) var invisible
export(bool) var interactable
export(String, MULTILINE) var required_tags

var root
var items = []

signal item_added
signal item_removed
signal released


func _is_empty():
	
	return len(items) == 0


func _add_item(item):
	
	for item_tag in required_tags.split(' '):
		if not item_tag in item.tags:
			return false
	
	
	if len(get_children()) < max_quantity:
		
		item.visible = not invisible
		
		if item.has_node('Collision'):
			item.get_node('Collision').disabled = true
		
		items.append(item)
		
		emit_signal('item_added', self, item)
		
		return true
	
	return false


func _remove_item(item):
	
	if _has_item(item):
		
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

		
		items.erase(item)
		
		emit_signal('item_removed', self, item)


func _has_item(item):
	
	return items.has(item)


func _push_front_into_container(new_container):
	
	if len(items) == 0:
		return
	
	var item = _release_front()
	
	var data = {
		'from': owner.get_path(),
		'to': item,
		'container': new_container
		}
	
	LinkHub._create('Contains', data)


func _release_front():
	
	if len(items) == 0:
		return
	
	var item = items[0]
	
	var data = {
		'from_node': owner,
		'to_node': item,
		'container': name
	}
	
	LinkHub._destroy('Contains', data)
	
	return item


func _release_all():
	
	var data = {
		'from_node': owner,
		'container': name
	}
	
	LinkHub._destroy('Contains', data)


func _get_item_position_offset(item):
	
	if item._has_tag('Offset-position'):
		
		var item_data = item._get_tag('Offset-position')
		
		var item_parent_name = item_data[0]
		var item_bone_name = item_data[1]
		var item_offset = item_data[2].split(',')
		
		return Vector3(float(item_offset[0]), float(item_offset[1]), float(item_offset[2])) if (
			(item_parent_name == '' or root.get_parent().name == item_parent_name) and \
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
			(item_parent_name == '' or root.get_parent().name == item_parent_name) and \
			(item_bone_name == '' or item_bone_name == bone_name)
			) else Vector3()
	
	return Vector3()


func _move_items():
	
	for item in items:
		
		var item_position_offset = _get_item_position_offset(item)
		var item_rotation_offset = _get_item_rotation_offset(item)
		
		item.global_transform = root.global_transform.translated(item_position_offset)
		
		item.global_transform.basis = root.global_transform.basis
		item.global_transform.basis = item.global_transform.basis.rotated(item.global_transform.basis.x, item_rotation_offset.x)
		item.global_transform.basis = item.global_transform.basis.rotated(item.global_transform.basis.y, item_rotation_offset.y)
		item.global_transform.basis = item.global_transform.basis.rotated(item.global_transform.basis.z, item_rotation_offset.z)
		
		item.force_update_transform()


func _reset_root():
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset


func _ready():
	
	root = BoneAttachment.new()
	root.name = name + 'Root'
	get_node(path).call_deferred('add_child', root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	_reset_root()


func _process(delta):
	
	_move_items()
