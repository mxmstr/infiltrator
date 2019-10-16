extends AnimationNodeAnimation

var node_name
var parent
var transitions = []


func _ready(_parent, _name):
	
	parent = _parent
	node_name = _name
	
	parent.connect('state_starting', self, '_on_state_starting')
	parent.connect('on_process', self, '_process')