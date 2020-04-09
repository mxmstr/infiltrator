extends Spatial

export(String, MULTILINE) var tags

signal entered_tree


func _enter_tree():
	
	for child in get_children():
		
		if child.get('make_unique') != null:
			
			Inf._make_unique(child)