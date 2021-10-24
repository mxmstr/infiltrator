extends Node

export var enabled = true
export(NodePath) var from
export(NodePath) var to

var check_nulls = true

var base_name
var from_node
var to_node


func _notification(what):
	
	if what == NOTIFICATION_INSTANCED:
		base_name = name


func _equals(other):
	
	return get_class() == other.get_class() and from == other.from and to == other.to


func _is_invalid():
	
	return (from_node and (not weakref(from_node).get_ref() or from_node.is_queued_for_deletion())) or \
		(to_node and (not weakref(to_node).get_ref() or to_node.is_queued_for_deletion()))


func _enter_tree():
	
	if not enabled:
		queue_free()
		return
	
#	if check_nulls:
#
#		if from.is_empty() or to.is_empty() or not has_node(from) or not has_node(to):
#			queue_free()
#			return
	
	if not from.is_empty():
		from_node = get_node(from)
	
	if not to.is_empty():
		to_node = get_node(to)
	
#	from_node.connect('tree_exited', self, 'queue_free')
#	to_node.connect('tree_exited', self, 'queue_free')


#func _process(delta):
#
#	if from_node and (not weakref(from_node).get_ref() or from_node.is_queued_for_deletion()) or \
#		to_node and (not weakref(to_node).get_ref() or to_node.is_queued_for_deletion()):
#		_destroy()
#		return


func _destroy():
	
	set_process(false)
	set_physics_process(false)
	queue_free()