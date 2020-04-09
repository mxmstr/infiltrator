extends 'res://Scripts/Link.gd'

var container


func _find_free_container():
	
	for child in from_node.get_children():
		
		if child.get_script() != null:
		
			var script_name = child.get_script().get_path().get_file()
			
			if script_name == 'Prop.Container.gd' and child._add_item(to_node):
				
				container = child.name
				return true
	
	return false


func _on_enter():
	
	if not _find_free_container():
		_on_exit()
	
	._on_enter()


func _on_execute(delta):
	
	var container_node = from_node.get_node(container)
	
	if not container_node._has_item(to_node):
		_on_exit()
	
	._on_execute(delta)


func _on_exit():
	
	var container_node = from_node.get_node(container)
	
	container_node._remove_item(to_node) if container_node != null else null
	
	._on_exit()