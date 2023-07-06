extends AnimationNodeBlend3

@export var blend3: String
@export var chain = false
@export_multiline var expression
@export var arguments: Dictionary

var node_name
var owner
var parent
var parameters
var connections = []
var advance = false

var exec_list = []

signal playing


func _evaluate():
	
	var result
	
	for exec in exec_list:
		
		result = exec.execute(arguments.values(), owner)
		
		if result == null:
		
			if exec.has_execute_failed():
				
				prints(owner.owner.name, node_name, exec.get_error_text())
			
			return 0
	
	return result


func __ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting',Callable(self,'_on_state_starting'))
	
	owner.connect('on_process',Callable(self,'__process'))
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)


func __process(delta):
	
	owner.set(parameters + node_name + '/blend_amount', _evaluate())
