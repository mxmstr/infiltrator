extends Node


func _establish_link(resource, data):
	
	var link = load('res://scenes/Links/' + resource + '.tscn').instance()
	
	for prop in data:
		link.set(prop, data[prop])
	
	add_child(link)