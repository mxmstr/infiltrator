extends AnimationNodeStateMachineTransition

var parent
var from
var to

var default_mode


func _on_travel_started(target_node):
	
	if target_node.priority > from.priority:
		switch_mode = SWITCH_MODE_IMMEDIATE
	else:
		switch_mode = default_mode


func _ready(_parent, _from, _to):
	
	parent = _parent
	from = _from
	to = _to
	
	default_mode = switch_mode
	
	parent.connect('on_process', self, '_process')
	parent.connect('travel_starting', self, '_on_travel_started')