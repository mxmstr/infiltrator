extends 'res://Scripts/AnimationTree.StateMachine.gd'

export(float) var level


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			print(['statemachine', node_name, level])
			
			owner.level = level


func _ready(_owner, _parent, _playback, _node_name):
	
	_parent.connect('state_starting', self, '_on_state_starting')
	
	._ready(_owner, _parent, _playback, _node_name)