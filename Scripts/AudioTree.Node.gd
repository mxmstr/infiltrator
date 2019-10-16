extends AnimationNodeAnimation

export(String) var path

var node_name
var parent
var transitions = []

signal on_enter


func _on_travel_starting(new_name):
	
	if node_name == new_name:
		
		emit_signal('on_enter')


func init(_parent, _node_name):
	
	parent = _parent
	node_name = _node_name
	
	parent.connect('travel_starting', self, '_on_travel_starting')