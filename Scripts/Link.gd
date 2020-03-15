extends Node

export var enabled = true
export(NodePath) var from
export(NodePath) var to

var from_node
var to_node


func _equals(other):
	
	return get_class() == other.get_class() and from == other.from and to == other.to


func _on_enter(): pass


func _on_execute(): pass


func _on_exit(): 
	
	queue_free()


func _ready():
	
	from_node = get_node(from)
	to_node = get_node(to)
	
	if enabled:
		_on_enter()
	else:
		set_process(false)


func _process(delta):
	
	_on_execute()
