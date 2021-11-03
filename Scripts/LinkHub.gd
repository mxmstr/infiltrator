extends Node


func _get_links(type, data={}):
	
	var links = []
	
	for link in $'/root/Mission/Links'.get_children():
		
		#prints('aaaaaaa', type, link.base_name)
		if not type == link.base_name:
			continue
		
		
		var props_match = true
		
		for prop in data:
			
#			prints(link.get(prop).name, data[prop].name)
			
			if link.get(prop) != data[prop]:
				props_match = false
				break
		
		if not props_match:
			continue
		
		
#		prints('fwfdsafdsa', link.name)
		links.append(link)
	
	return links


func _create(type, data):
	
	var new_link = Meta.preloader.get_resource('res://Scenes/Links/' + type + '.link.tscn').instance()
	
	for prop in data:
		new_link.set(prop, data[prop])
	
	for link in $'/root/Mission/Links'.get_children():
		if is_instance_valid(link) and not link.is_queued_for_deletion() and link._equals(new_link):
			return
	
	$'/root/Mission/Links'.add_child(new_link)
	
	return new_link


func _destroy(type, data={}):
	
	var freed = []
	
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
		
		
		link._destroy()
		
		if not link.to_node in freed:
			freed.append(link.to_node)
	
	return freed
