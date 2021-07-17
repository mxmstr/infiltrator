extends "res://Scripts/AnimationTree.Animation.gd"

export(String) var driver_command


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			if owner.owner.has_node('AIDriver'):
				owner.owner.get_node('AIDriver')._start_state(driver_command)
