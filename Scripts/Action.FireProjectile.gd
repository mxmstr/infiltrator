extends "res://Scripts/Action.gd"

onready var reception = get_node_or_null('../Reception')
onready var chamber = get_node_or_null('../Chamber')
onready var magazine = get_node_or_null('../Magazine')


func _on_action(_state, data): 
	
	new_state = _state
	
	if new_state == state:
		
		if _play(animation_list[0]):
			
			reception._reflect('UseReact')


func _ready():
	
	if tree.is_empty():
		return
	
	attributes[animation_list[0]].speed = float(owner._get_tag('FireRate'))