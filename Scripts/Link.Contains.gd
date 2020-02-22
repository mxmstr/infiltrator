extends 'res://Scripts/Link.gd'

var container


func _contain():
	
	var actor = get_node(from)
	var item = get_node(to)


func _find_free_container():
	
	var actor = get_node(from)
	var item = get_node(to)
	
	for child in actor.get_children():
		
		if child.get_script() != null:
		
			var script_name = child.get_script().get_path().get_file()
			
			if script_name == 'Prop.Container.gd' and child._add_item(item):
				container = child
				return true
	
	return false


func _on_enter():
	
	if not _find_free_container():
		_break()


func _on_exit():
	
	var item = get_node(to)
	
	container._remove_item(item) if container != null else null


func _process(delta):
	
	var actor = get_node(from)
	var item = get_node(to)
	
	
	if not container._has_item(item):
		_break()
		return
