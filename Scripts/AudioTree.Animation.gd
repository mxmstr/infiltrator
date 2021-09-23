extends 'res://Scripts/AnimationTree.Animation.gd'

export(float) var level


func _on_state_starting(new_name):
	
	._on_state_starting(new_name)
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			owner.level = level


func _ready(_owner, _parent, _parameters, _name):
	
	._ready(_owner, _parent, _parameters, _name)
	
	var stream = owner.get_node('AnimationPlayer').get_animation(animation).audio_track_get_key_stream(0, 0)
	
#	if stream:
#		prints(animation, stream.data)
