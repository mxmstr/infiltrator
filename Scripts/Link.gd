extends Node

export var enabled = true
export(NodePath) var from
export(NodePath) var to

var from_node
var to_node


func _equals(other):
	
	return get_class() == other.get_class() and from == other.from and to == other.to


func _check_actors_freed():
	
	if from_node != null and not weakref(from_node).get_ref():
		from_node = get_node(from)
	
	if to_node != null and not weakref(to_node).get_ref():
		to_node = get_node(to)


func _on_enter(): pass


func _on_execute(delta): pass


func _on_exit(): 
	
	queue_free()


func _ready():
	
	if enabled:
		
		from_node = get_node(from)
		to_node = get_node(to)
		
		if null in [from_node, to_node]:
			set_process(false)
			return
		
		_on_enter()
		
	else:
		set_process(false)


func _process(delta):
	
	_check_actors_freed()
	
	_on_execute(delta)
