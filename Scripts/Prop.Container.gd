extends Node

export(NodePath) var path
export(String) var bone_name
export(Vector3) var position_offset
export(Vector3) var rotation_degrees_offset
export(int) var max_quantity
export(int) var max_item_size
export(bool) var invisible
export(bool) var interactable

var root
var items = []

signal released


func _is_empty():
	
	return len(items) == 0


func _add_item(item):
	
	if len(get_children()) < max_quantity and true:#max_item_size:
		
		item.visible = not invisible
		item.get_node('Collision').disabled = true
		
		items.append(item)
		
		return true
	
	return false


func _remove_item(item):
	
	if _has_item(item):
		items.erase(item)


func _has_item(item):
	
	return items.has(item)


func _release():
	
	for item in items:
		
		var last_transform = item.global_transform.origin
		var last_rotation = item.rotation
		
		item.visible = true
		item.get_node('Collision').disabled = false
		
		if item is RigidBody:

			var item_name = item.name
			var new_item = load(item.filename).instance()
			
			$'/root/Game/Actors'.add_child(new_item)
			item.name = item_name + '_'
			
			new_item.name = item_name
			new_item.global_transform.origin = last_transform
			new_item.rotation = last_rotation

			item.queue_free()
		
		items.erase(item)


func _ready():
	
	root = BoneAttachment.new()
	get_node(path).add_child(root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset


func _process(delta):
	
	for item in items:
		
		item.global_transform.origin = root.global_transform.origin
		item.global_transform.basis = root.global_transform.basis
