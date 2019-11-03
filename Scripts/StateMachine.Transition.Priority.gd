extends AnimationNodeStateMachineTransition

var parent
var from
var to


func _on_travel_started(target_node):
	
	disabled = not target_node.priority > from.priority


func _ready(_parent, _from, _to):
	
	parent = _parent
	from = _from
	to = _to
	
	parent.connect('travel_starting', self, '_on_travel_started')