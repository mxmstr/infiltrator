extends Node

export(String) var context


func set_context(_context):
	
	get_node(context).disable()
	
	context = _context
	
	get_node(context).enable()


func _ready():
	
	for child in get_children():
		child.disable()
	
	set_context(context)
