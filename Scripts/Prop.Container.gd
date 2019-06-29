extends Spatial

export(int) var max_quantity
export(int) var max_item_size
export(bool) var invisible
export(bool) var interactable


func _is_empty():
	
	return len(get_children()) == 0


func _contain(item):
	
	item.get_parent().remove_child(item)
	add_child(item)
	
	item.global_transform = global_transform
	item.visible = not invisible
	item.get_node('Collision').disabled = true

#	if item.get('gravity_scale') != null:
#		item.gravity_scale = 0
#	if item.get('mode') != null:
#		item.mode = 1


func _release():
	
	for child in get_children():
		child.visible = true
		child.get_node('Collision').disabled = false
		var last_transform = child.global_transform
		
		child.get_parent().remove_child(child)
		$'/root/Game/Actors'.add_child(child)
		
		child.global_transform = last_transform


func _add_item(item):
	
	if len(get_children()) < max_quantity and \
		true:#max_item_size:
		_contain(item)
		return true
	
	return false