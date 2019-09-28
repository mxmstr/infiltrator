extends AnimationNodeStateMachineTransition

export(String, 'Greater Than', 'Less Than') var assertion = 'None'
export(String) var target
export(String) var method
export(float) var value

var parent


func _on_target_signal(_value):
	
	match assertion:
		
		'Equals': return value == _value
		'Greater Than': return value >= _value
		'Less Than': return value <= _value


func _ready(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, '_process')


func _process():
	
	disabled = not _on_target_signal(parent.get_parent().get_node(target).call(method))