extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var to_interaction


func _ready():
	
	if has_node(from) and has_node(to) \
		and from_interaction != null and to_interaction != null:
		
		var sender = get_node(from).get_node('Behavior').get_node(from_interaction)
		var receiver = get_node(to).get_node('Behavior')
		
		sender.connect('on_enter', receiver, 'start_interaction', [to_interaction])