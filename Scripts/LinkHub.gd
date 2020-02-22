extends Node


func _establish_link(resource, data):
	
	var link = load('res://scenes/Links/' + resource + '.tscn').instance()
	
	for prop in data:
		link.set(prop, data[prop])
	
	for child in get_children():
		if child._equals(link):
			return
	
	add_child(link)
