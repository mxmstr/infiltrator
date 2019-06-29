extends Node

export(String, 'Exit') var action
export(bool) var enter_only
export(bool) var eval_false
export(String) var target
export(String) var method


func _evaluate(is_entering=false):
	
	var condition = get_node(target).call(method)
	
	return (
		(enter_only and not is_entering) or \
		(eval_false and not condition) or \
		condition
		) 