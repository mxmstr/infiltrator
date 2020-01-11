extends AnimationNodeAnimation

var node_name
var owner
var parent
var parameters
var transitions = []


func _ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	parent.connect('state_starting', self, '_on_state_starting')
	parent.connect('on_process', self, '_process')