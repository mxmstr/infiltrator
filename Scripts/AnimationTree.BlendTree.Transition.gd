tool
extends AnimationNodeTransition

var owner
var parent
var parameters


func _editor_ready(_owner, _parent, _parameters, _name):
	
	print('asdf')


func _ready(_owner, _parent, _parameters):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
