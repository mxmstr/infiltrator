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


func _is_empty():
	
	return len(root.get_children()) == 0


func _contain(item):
	
	item.get_parent().remove_child(item)
	root.add_child(item)
	
	item.global_transform.origin = root.global_transform.origin
	item.global_transform.basis = root.global_transform.basis
	item.visible = not invisible
	item.get_node('Collision').disabled = true


func _release():
	
	for child in get_children():
		
		var last_transform = child.global_transform.origin
		var last_rotation = child.rotation
		
		child.visible = true
		child.get_node('Collision').disabled = false
		
		
		if child is RigidBody:
			
			var new_child = load(child.filename).instance()
			$'/root/Game/Actors'.add_child(new_child)
			new_child.global_transform.origin = last_transform
			new_child.rotation = last_rotation
			
			child.queue_free()
		
		else:
			
			child.get_parent().remove_child(child)
			$'/root/Game/Actors'.add_child(child)
			child.global_transform.origin = last_transform
			child.rotation = last_rotation


func _add_item(item):
	
	if len(get_children()) < max_quantity and true:#max_item_size:
		_contain(item)
		return true
	
	return false


func _ready():
	
	root = BoneAttachment.new()
	get_node(path).add_child(root)
	
	if bone_name != '':
		root.bone_name = bone_name
	
	root.translation = position_offset
	root.rotation_degrees = rotation_degrees_offset