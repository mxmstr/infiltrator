extends 'res://Scripts/Response.gd'

onready var behavior = get_node_or_null('../Behavior')


func _on_stimulate(stim, data):
	
	if stim == 'UseReact':
		
		behavior._start_state('UseReact')