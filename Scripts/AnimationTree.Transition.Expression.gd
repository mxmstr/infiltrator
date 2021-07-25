extends 'res://Scripts/AnimationTree.Transition.gd'

export(String) var transition_expression

export(String, 'process', 'state_starting', 'travel_starting') var update_mode = 'process'

export(String, MULTILINE) var expression
export(Dictionary) var arguments
export(float) var wait_for_frame


func _evaluate():
	
	var exec = Expression.new()
	exec.parse(expression, arguments.keys())
	var result = exec.execute(arguments.values(), owner)
	
	if exec.has_execute_failed():
		print(exec.get_error_text())
	
#	if owner.owner.name == 'Pistol':
#		prints(owner.name, result, 
#			true if owner.get_node('../Chamber')._is_empty() and not \
#			owner.get_node('../Magazine')._is_empty() and not \
#			owner.get_node('../Magazine').items[0].get_node('Container')._is_empty() else false)
	
	return result


func _update():
	
	var _args = []
	
	for arg in arguments:
		
		if arg is String and arg.begins_with('$'):
			arg = owner.get_indexed(arg.replace('$', ''))
		
		_args.append(arg)
	
	disabled = not _evaluate()


func _on_state_starting(new_name):
	
	var from_name = parent.get_node_name(from)
	
	if from_name == new_name and update_mode == 'state_starting':
		_update()


func _on_travel_starting(new_name):
	
	if update_mode == 'travel_starting':
		_update()


func _ready(_owner, _parent, _parameters, _from, _to):
	
	._ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	if parent != null and parent.has_user_signal('travel_starting'):
		parent.connect('travel_starting', self, '_on_travel_starting')
	
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	if update_mode == 'process':
		_update()
