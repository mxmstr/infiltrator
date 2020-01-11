extends AnimationNodeStateMachineTransition

var owner
var parent
var parameters
var from
var to


func _on_travel_starting(new_node_name, new_node):
	
	if new_node.get('priority') == null:
		disabled = true
		return
	
	disabled = not new_node.priority > from.priority


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('travel_starting', self, '_on_travel_starting')