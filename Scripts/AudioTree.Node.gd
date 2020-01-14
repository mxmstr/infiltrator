extends AnimationNodeAnimation

export(float) var level

var node_name
var owner
var parent
var parameters
var connections = []


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
		
			owner.get_node('AudioStreamPlayer3D').unit_db = level


func _ready(_owner, _parent, _parameters, _node_name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _node_name
	
	parent.connect('state_starting', self, '_on_state_starting')