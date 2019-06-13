extends Node

export(String, 'Exit') var action
export(String) var target
export(String) var method


func _evaluate():
	
	return get_node(target).call(method)