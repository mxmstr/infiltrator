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
		
		return true
	
	return false


func _remove_item(item):
	
	if _has_item(item):
		
		var last_transform = item.global_transform.origin
		var last_rotation = item.rotation

		item.visible = true
		
		if item.has_node('Collision'):
			item.get_node('Collision').disabled = false

		if item is RigidBody:

			var item_name = item.name
			var new_item = load(item.filename).instance()

			$'/root/Mission/Actors'.add_child(new_item)
			item.name = item_name + '_'

			new_item.name = item_name
			new_item.global_transform.origin = last_transform
			new_item.rotation = last_rotation

			if new_item.has_node('Movement'):
				new_item.get_node('Movement')._set_speed(release_speed)
				new_item.get_node('Movement')._set_direction(release_direction)

			item.queue_free()
		
		items.erase(item)


func _has_item(item):
	
	return items.has(item)


func _push_front_into_container(new_container):
	
	if len(items) == 0:
		return
	
	var item = _release_front()
	
	var data = {
		'from': owner.get_path(),
		'to': item,
		'container': get_node(new_container)
		}
	
	LinkHub._create('Contains', data)


func _release_front():
	
	if len(items) == 0:
		return
	
	var item = items[0]
	
	var data = {
		'from_node': owner,
		'to_node': item,
		'container': self
	}
	
	LinkHub._destroy('Contains', data)
	
	return item


func _release_all():
	
	var data = {
		'from_node': owner,
		'container': self
	}
	
	LinkHub._destroy('Contains', data)


func _ready():
	
	root = BoneAttachment.new()
	get_node(path).call_deferred('add_child', root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset


func _process(delta):
	
	for item in items:
		
		item.global_transform.origin = root.global_transform.origin
		item.global_transform.basis = root.global_transform.basis
