extends 'res://Scripts/AnimationTree.Node.gd'

export(String) var randomizer

var last = -1


func _on_state_starting(new_node_name):
	
	if node_name == new_node_name:
		
		var enabled_idx = last
		
		while enabled_idx == last:
			enabled_idx = randi() % len(connections)
		
		for idx in range(len(connections)):
			connections[idx].disabled = idx != enabled_idx
		
		last = enabled_idx
		