extends Node

onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _process(delta):
	
	if chamber._is_empty() and not magazine._is_empty() and \
		not magazine.items[0].get_node('Container')._is_empty():
		
		var projectile = magazine.items[0].get_node('Container')._release_front()
		Meta.CreateLink(owner, projectile, 'Contains', { 'container': 'Chamber' } )