extends AnimationNodeAnimation

var parent
var node_name
var transitions = []
var last = -1


func _on_travel_starting(new_anim):
	
	if node_name == new_anim:
		
		var enabled_idx = last
		
		while enabled_idx == last:
			enabled_idx = randi() % len(transitions)
		
		for idx in range(len(transitions)):
			transitions[idx].disabled = idx != enabled_idx
		
		last = enabled_idx


func _init(_parent, _node_name):
	
	parent = _parent
	node_name = _node_name
	
	parent.connect('travel_starting', self, '_on_travel_starting')