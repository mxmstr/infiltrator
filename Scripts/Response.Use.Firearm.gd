extends 'res://Scripts/Response.gd'

onready var behavior = get_node_or_null('../Behavior')
onready var reception = get_node_or_null('../Reception')
onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _on_stimulate(stim, data):
	
	if stim == 'Use':
		
		if not chamber._is_empty():
			
			behavior._start_state(owner._get_tag('UseAction'))
		
		elif magazine._is_empty():
			
			reception._reflect('EmptyReact')