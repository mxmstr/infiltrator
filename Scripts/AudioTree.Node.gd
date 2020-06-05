extends 'res://Scripts/AnimationTree.Node.gd'

export(String) var node

export(float) var level


func _on_state_starting(new_name):
	
	._on_state_starting(new_name)
	
	if node_name == new_name:
		
		var playback = owner.get(parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			owner.level = level
