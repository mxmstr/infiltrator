extends AnimationNodeStateMachineTransition

export(String, 'True', 'False', 'Null', 'NotNull') var assertion
export(String) var target
export(String) var signal_name


func on_target_signal(value):
	
	match assertion:
		
		'True':
			disabled = not value
		'False':
			disabled = value
		'Null':
			disabled = value != null
		'NotNull':
			disabled = value == null


func init(parent):
	
	parent.get_node(target).connect(signal_name, self, 'on_target_signal')
