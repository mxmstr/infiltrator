extends 'res://Scripts/Link.gd'


func _find_free_container(node):
	
	if node.get_script() != null:
	
		var script_name = node.get_script().get_path().get_file()
		
		if script_name == 'Prop.Container.gd' and \
			node._add_item(get_node(to)):
			return
	
	for child in node.get_children():
		_find_free_container(child)


func _on_enter():
	
	_find_free_container(get_node(from))