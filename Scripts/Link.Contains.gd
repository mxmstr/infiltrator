extends 'res://Scripts/Link.gd'

var container


func _contain():
	
	var actor = get_node(from)
	var item = get_node(to)


func _find_free_container():
	
	for child in from_node.get_children():
		
		if child.get_script() != null:
		
			var script_name = child.get_script().get_path().get_file()
			
			if script_name == 'Prop.Container.gd' and child._add_item(to_node):
				container = child
				return true
	
	return false


func _on_enter():
	
	if not _find_free_container():
		_on_exit()
	
	._on_enter()


func _on_exit():
	
	container._remove_item(to_node) if container != null else null
	
	._on_exit()


func _process(delta):
	
	if not container._has_item(to_node):
		_on_exit()
