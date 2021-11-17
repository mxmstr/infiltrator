extends AnimationNodeBlend3

export(String) var blend3
export var chain = false
export(String, MULTILINE) var expression
export(Dictionary) var arguments

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


func _ready(_owner, _parent, _parameters, _name):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	node_name = _name
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	owner.connect('on_process', self, '_process')
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)


func _process(delta):
	
	owner.set(parameters + node_name + '/blend_amount', _evaluate())
