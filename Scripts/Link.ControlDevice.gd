extends 'res://Scripts/Link.gd'

export(String) var from_interaction
export(String) var from_signal
export(String) var to_interaction


func _ready():
	
	var sender = get_node(from).get_node('Behavior').get_node(from_interaction)
	var receiver = get_node(to).get_node('Behavior')
	
	sender.connect(from_signal, receiver, 'start_interaction', [to_interaction])