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
	
	items.append(item)
	
	emit_signal('item_added', self, item)


func _remove_item(item):
	
	if _has_item(item):
		
		items.erase(item)
		
		emit_signal('item_removed', self, item)


func _has_item(item):
	
	return items.has(item)


func _has_item_with_tag(tag):
	
	for item in items:
		if item._has_tag(tag):
			return true
	
	return false


func _push_front_into_container(new_container, new_):
	
	if len(items) == 0:
		return
	
	var item = _release_front()
	
	Meta.CreateLink(owner, item, 'Contains', {'container': new_container})


func _release_front():
	
	if len(items) == 0:
		return
	
	var item = items[0]
	
	Meta.DestroyLink(owner, item, 'Contains', {'container': name})
	
	return item


func _release_all():
	
	Meta.DestroyLink(owner, null, 'Contains', {'container': name})


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
