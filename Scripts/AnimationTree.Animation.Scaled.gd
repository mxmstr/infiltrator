extends 'res://Scripts/AnimationTree.Animation.gd'

export(String, MULTILINE) var expression
export(Dictionary) var arguments

var exec_list = []


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
	
	._ready(_owner, _parent, _parameters, _name)
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)
	
	
	scale = _evaluate()
