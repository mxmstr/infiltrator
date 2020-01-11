extends AnimationNodeAnimation

var owner
var parent
var playback
var node_name
var connections = []
var last = -1


func _on_travel_starting(new_node_name, new_node):
	
	if node_name == new_node_name:
		
		var enabled_idx = last
		
		while enabled_idx == last:
			enabled_idx = randi() % len(connections)
		
		for idx in range(len(connections)):
			connections[idx].disabled = idx != enabled_idx
		
		last = enabled_idx


func _ready(_owner, _parent, _playback, _node_name):
	
	print('randomizer')
	owner = _owner
	parent = _parent
	playback = _playback
	node_name = _node_name
	
	owner.connect('travel_starting', self, '_on_travel_starting')