extends "res://Scripts/Action.8Way.gd"


func _process(delta):
	
	if behavior.current_state == state:
		
		_set_blendspace_position()
