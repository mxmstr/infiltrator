extends AnimationNodeStateMachineTransition

export(String, 'None', 'True', 'False', 'Null', 'NotNull') var assertion = 'None'
export(String) var target
export(String) var method

var parent
var from
var to

var default_mode


func _on_target_signal(value):
	
	match assertion:
		
		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func _ready(_parent, _from, _to):
	
	parent = _parent
	from = _from
	to = _to
	
	default_mode = switch_mode
	
	parent.connect('on_process', self, '_process')


func _process():
	
	if _on_target_signal(parent.get_parent().get_node(target).call(method)):
		switch_mode = SWITCH_MODE_IMMEDIATE
	else:
		switch_mode = default_mode