extends AnimationNodeStateMachineTransition

var owner
var parent
var parameters
var from
var to


func __ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
