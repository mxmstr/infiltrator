extends Node


func _create(type, data):
	
	var new_link = load('res://scenes/Links/' + type + '.tscn').instance()
	
	for prop in data:
		new_link.set(prop, data[prop])
	
	for link in $'/root/Mission/Links'.get_children():
		if link._equals(new_link):
			return
	
	$'/root/Mission/Links'.add_child(new_link)


func _destroy(type, data={}):
	
	for link in $'/root/Mission/Links'.get_children():
		
		if not type in link.name:
			continue
		
		
		var props_match = true
		
		for prop in data:
			
			if link.get(prop) != data[prop]:
				props_match = false
				break
		
		if not props_match:
			continue
		
		
		link._on_exit()
