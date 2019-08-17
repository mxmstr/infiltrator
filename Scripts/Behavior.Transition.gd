extends AnimationNodeStateMachineTransition

export(String, 'True', 'False', 'Null', 'NotNull') var assertion
export(String) var target
export(String) var signal_name


func on_target_signal(value):
	
	match assertion:
		
		'True':
			auto_advance = value
		'False':
			auto_advance = not value
		'Null':
			auto_advance = value == null
		'NotNull':
			auto_advance = value != null


func init(parent):
	
	parent.get_node(target).connect(signal_name, self, 'on_target_signal')


#func process(behavior):
#
#	var condition = behavior.get_node(target).call(method)
#
#	auto_advance = (
#		(eval_false and not condition) or \
#		condition
#		)
