extends 'res://Scripts/Response.gd'

onready var reception = get_node_or_null('../Reception')
onready var audio = get_node_or_null('../Audio')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Map'):
			
			owner.translation = data.position
			
			Meta.AddActor('Particles/Smoke', owner.translation)
			Meta.AddActor('Particles/Sparks', owner.translation, null, data.direction)
			
			owner.queue_free()
		
		elif data.source._has_tag('Hitbox'):
			
			Meta.AddActor('Particles/BloodSquirt', owner.translation, null, data.direction)
			
			owner.queue_free()
			
