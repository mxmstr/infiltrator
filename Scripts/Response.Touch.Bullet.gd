extends 'res://Scripts/Response.gd'

onready var reception = get_node_or_null('../Reception')
onready var audio = get_node_or_null('../Audio')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Map'):
			
			owner.global_transform.origin = data.position
			
			Meta.AddActor('Particles/Smoke', owner.position)
			Meta.AddActor('Particles/Sparks', owner.position, null, data.direction)
			
			owner.queue_free()
		
		elif data.source._has_tag('Hitbox'):
			
			Meta.AddActor('Particles/BloodSquirt', owner.position, null, data.direction)
			
			owner.queue_free()
			