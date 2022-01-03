extends Node

onready var behavior = get_node_or_null('../Behavior')
onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _process(delta):
	
	if chamber._is_empty() and not magazine._is_empty():
		
		var projectile = magazine._release_front()
		Meta.CreateLink(owner, projectile, 'Contains', { 'container': 'Chamber' } )
		
		while not chamber._is_full():
			
			var clone = Meta.AddActor(projectile.system_path)#, null, null, null, { 'Shooter': shooter })
			#clone._set_tag('Shooter', projectile._get_tag('Shooter'))
			Meta.CreateLink(owner, clone, 'Contains', { 'container': 'Chamber' } )
