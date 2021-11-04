extends 'res://Scripts/Response.gd'

onready var reception = get_node_or_null('../Reception')
onready var audio = get_node_or_null('../Audio')


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Bullet'):
			
			var damage_mult = 1.0
			
			if data.source._has_tag('DamageMult'):
				damage_mult = float(data.source._get_tag('DamageMult'))
			
			var damage = float(data.source._get_tag('Damage')) * damage_mult
			var force = float(data.source._get_tag('Force'))
			var direction = data.source.transform.basis.z.normalized()
			
			Meta.StimulateActor(owner.owner, 'Damage', data.source, damage, data.position, direction)
			Meta.StimulateActor(owner.owner, 'Push', data.source, force, data.position, direction)
			audio._start_state('Damage')
			reception._reflect()
		
		if data.source._has_tag('Punch'):
			
			var disarm_chance = float(data.source._get_tag('DisarmChance'))
			var damage = float(data.source._get_tag('Damage'))
			var force = float(data.source._get_tag('Force'))
			var direction = data.source._get_tag('Shooter').transform.basis.z.normalized()
			
			Meta.StimulateActor(owner.owner, 'Damage', data.source, damage, data.position, direction)
			Meta.StimulateActor(owner.owner, 'Push', data.source, force, data.position, direction)
			audio._start_state('Damage')
			
			if randf() < disarm_chance:
				owner.owner.get_node('Behavior')._start_state('Drop')
			
			data.source.queue_free()