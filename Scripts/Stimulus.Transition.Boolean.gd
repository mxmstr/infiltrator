extends AnimationNodeStateMachineTransition

export(String, 'None', 'True', 'False', 'Null', 'NotNull') var assertion = 'None'
export(String) var target
export(String) var method

var parent


func _on_target_signal(value):
	
	match assertion:
		
		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func _ready(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, '_process')


func _process():
	
	disabled = not _on_target_signal(parent.get_parent().get_node(target).call(method))