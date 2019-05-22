extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var to_interaction


func _on_sender_enter():
	
	if has_node(to) and to_interaction != null:
		
		var receiver = get_node(to).get_node('Behavior')
		
		receiver.start_interaction(to_interaction)


func _on_enter():
	
	if has_node(from) and from_interaction != null:
		
		var sender = get_node(from).get_node('Behavior').get_node(from_interaction)
		
		sender.connect('on_enter', self, '_on_sender_enter')#receiver, 'start_interaction', [to_interaction])