extends AnimationNodeAnimation

var parent
var node_name
var transitions = []
var last = -1


func _on_travel_starting(new_node_name, new_node):
	
	if node_name == new_node_name:
		
		var enabled_idx = last
		
		while enabled_idx == last:
			enabled_idx = randi() % len(transitions)
		
		for idx in range(len(transitions)):
			transitions[idx].disabled = idx != enabled_idx
		
		last = enabled_idx


func _ready(_parent, _node_name):
	
	parent = _parent
	node_name = _node_name
	
	parent.connect('travel_starting', self, '_on_travel_starting')