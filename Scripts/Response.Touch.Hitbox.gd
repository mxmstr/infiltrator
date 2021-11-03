extends 'res://Scripts/Response.gd'

onready var reception = get_node_or_null('../Reception')
onready var audio = get_node_or_null('../Audio')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Bullet'):
			
			Meta.StimulateActor(owner.owner, 'Damage', data.source, data.intensity, data.position, data.direction)
			Meta.StimulateActor(owner.owner, 'Push', data.source, data.intensity, data.position, data.direction)
			audio._start_state('Damage')
			reception._reflect()
		
		if data.source._has_tag('Punch'):
			
			Meta.StimulateActor(owner.owner, 'Damage', data.source, data.intensity, data.position, data.direction)
			Meta.StimulateActor(owner.owner, 'Push', data.source, data.intensity, data.position, data.direction)
			audio._start_state('Damage')
			data.source.queue_free()