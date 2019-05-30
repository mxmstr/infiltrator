extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var to_interaction


func _on_sender_enter():
	
	for receiver in to:
		
		if has_node(to) and to_interaction != null:
			get_node(to).get_node('Behavior')._start_interaction(to_interaction)


func _on_enter():
	
	for sender in from:
	
		if has_node(sender) and from_interaction != null:
			
			var sender_action = get_node(sender).get_node('Behavior').get_node(from_interaction)
			sender_action.connect('on_enter', self, '_on_sender_enter')