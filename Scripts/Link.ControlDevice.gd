extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var to_interaction


func _on_sender_enter():
	
	var receiver = to
	
	if has_node(receiver) and to_interaction != null:
		get_node(receiver).get_node('Behavior')._start_interaction(to_interaction)


func _ready():
	
	if is_queued_for_deletion():
		return
	
	if from_node.has_node('Behavior') and from_interaction != null:
		
		var sender_action = from_node.get_node('Behavior').tree_root.get_node(from_interaction)
		#sender_action.connect('state_starting', self, '_on_sender_enter')
