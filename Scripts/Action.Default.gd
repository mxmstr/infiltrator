extends "res://Scripts/Action.gd"


func _on_action(state, data):
	
	._on_action(state, data)
	
	if state == 'Default':
		
		_play(animation)
