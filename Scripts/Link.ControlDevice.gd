extends 'res://Scripts/Link.gd'

@export var from_interaction: String
@export var to_interaction: String


func _on_sender_enter():
	
	var receiver = to
	
	if has_node(receiver) and to_interaction != null:
		get_node(receiver).get_node('Behavior')._start_interaction(to_interaction)


func _ready():
	
	if is_queued_for_deletion():
		return
	
	if from_node.has_node('Behavior') and from_interaction != null:
		
		var sender_action = from_node.get_node('Behavior').tree_root.get_node(from_interaction)
		#sender_action.connect('state_starting',Callable(self,'_on_sender_enter'))
