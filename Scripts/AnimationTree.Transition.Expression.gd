extends 'res://Scripts/AnimationTree.Transition.gd'

@export var transition_expression: String

@export_enum('process', 'state_starting', 'travel_starting') var update_mode = 'process'

@export_multiline var expression
@export var arguments: Dictionary
@export var delay: float

var exec_list = []
var timeout = false


func _evaluate():
	
	for exec in exec_list:
		
		var result = exec.execute(arguments.values(), owner)
#		if 'Anderson' in owner.owner.name:
#			print(owner.data.source._has_tag('Item'))
		
		if not result:
			
			if exec.has_execute_failed():
				
				prints('transition_expression', owner.owner.name, owner.name, exec_list.find(exec), expression, exec.get_error_text())
			
			return false
	
	return true


func _update():
	
	if delay > 0 and not timeout:
		advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED
	
	var _args = []
	
	for arg in arguments:
		
		if arg is String and arg.begins_with('$'):
			arg = owner.get_indexed(arg.replace('$', ''))
		
		_args.append(arg)
	
	advance_mode = _evaluate()


func _on_state_starting(new_name):
	
	var from_name = parent.get_node_name(from)
	
	if from_name == new_name:
		
		if delay > 0:
			owner.get_tree().create_timer(delay).connect('timeout',Callable(self,'set').bind('timeout', true))
		
		if update_mode == 'state_starting':
			_update()


func _on_travel_starting(new_name):
	
	if update_mode == 'travel_starting':
		_update()


func __ready(_owner, _parent, _parameters, _from, _to):
	
	super.__ready(_owner, _parent, _parameters, _from, _to)
	
#	if owner.name == 'Behavior':
#		prints(owner.owner.name, owner.name, self)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
		owner.get(parent.parameters + 'playback').connect('pre_process',Callable(self,'__process').bind(0))
	
	if parent != null and parent.has_user_signal('travel_starting'):
		parent.connect('travel_starting',Callable(self,'_on_travel_starting'))
	
#	owner.connect('on_process',Callable(self,'_process'))
	
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)


func __process(delta):
	
	if update_mode == 'process':
		
#		if owner.owner.name == 'Infiltrator' and transition_expression in ['fdsa', 'asdf']:
#			prints(transition_expression, not disabled)
		
		_update()
