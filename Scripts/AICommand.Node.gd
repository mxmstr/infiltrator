extends "res://Scripts/AnimationTree.Node.gd"

export(Array, Dictionary) var triggers


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			pass
#			if owner.owner.has_node('AIDriver'):
#				owner.owner.get_node('AIDriver')._start_state(driver_command)