extends Node

export var enabled = true
export(NodePath) var from
export(NodePath) var to

var from_node
var to_node


func _equals(other):
	
	return get_class() == other.get_class() and from == other.from and to == other.to


func _enter_tree():
	
	if not enabled:
		queue_free()
	
	
	from_node = get_node(from)
	to_node = get_node(to)
	
	if null in [from_node, to_node]:
		queue_free()
	
	
	from_node.connect('tree_exited', self, 'queue_free')
	to_node.connect('tree_exited', self, 'queue_free')