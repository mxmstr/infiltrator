extends 'res://Scripts/Response.gd'

onready var behavior = get_node_or_null('../Behavior')
onready var movement = get_node_or_null('../Movement')
onready var stamina = get_node_or_null('../Stamina')
onready var voice_audio = get_node_or_null('../VoiceAudio')


func _on_stimulate(stim, data):
	
	if stim == 'Push' and stamina.hp > 0:
		
		var force = float(data.intensity)#data.source._get_tag('Force'))
		
		movement.velocity += force * Vector3(data.direction.x, 0, data.direction.z)
	
	
	if stim == 'Damage' and stamina.hp > 0:
		
		var damage = int(data.intensity)#data.source._get_tag('Damage'))
		stamina._damage(damage)
		
		voice_audio._start_state('Oof')
		
		if stamina.hp == 0:
		
			behavior._start_state('Die')