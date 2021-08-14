extends 'res://Scripts/AnimationTree.Transition.gd'

export(String) var transition_expression

export(String, 'process', 'state_starting', 'travel_starting') var update_mode = 'process'

export(String, MULTILINE) var expression
export(Dictionary) var arguments
export(float) var wait_for_frame

var exec_list = []


func _evaluate():
	
	for exec in exec_list:
		
		var result = exec.execute(arguments.values(), owner)
		
		if not result:
		
			if exec.has_execute_failed():
				
				prints(owner.owner.name, from.node_name, exec.get_error_text())
			
			return false
	
	return true


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
	
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)


func _process(delta):
	
	if update_mode == 'process':
		
#		if owner.owner.name == 'Infiltrator' and transition_expression in ['fdsa', 'asdf']:
#			prints(transition_expression, not disabled)
		
		_update()
