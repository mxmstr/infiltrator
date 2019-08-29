extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var to_interaction


func _on_sender_enter():
	
	var receiver = to
	
	if has_node(receiver) and to_interaction != null:
		get_node(receiver).get_node('Behavior')._start_interaction(to_interaction)


func _on_enter():
	
	var sender = from
	
	if has_node(sender) and get_node(sender).has_node('Behavior') and from_interaction != null:
		
		var sender_action = get_node(sender).get_node('Behavior').tree_root.get_node(from_interaction)
		sender_action.connect('on_enter', self, '_on_sender_enter')