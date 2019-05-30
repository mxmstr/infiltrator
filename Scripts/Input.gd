extends Node

export(int) var device
export(String) var context


func _on_interaction_started(interaction):
	
	set_context(interaction.input_context)


func set_context(_context):
	
	get_node(context).disable()
	
	context = _context
	
	get_node(context).enable()


func _ready():
	
	for child in get_children():
		child.disable()
	
	set_context(context)
	
	$'../Behavior'.connect('interaction_started', self, '_on_interaction_started')