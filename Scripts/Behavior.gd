extends 'res://Scripts/AnimationTree.gd'


func _get_visible_interactions():
	
	var interactions = []
	
	for node in tree_root.nodes:
		if node.has_method('_is_visible') and node._is_visible():# and tree_root.can_travel(node.node_name):
			interactions.append(node.node_name)
	
	return interactions


func _has_interaction(_name):
	
	return false#has_node(_name)


func _set_skeleton():
	
	var skeleton = $'../Model'.get_child(0)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(skeleton)


func _ready():
	
	_set_skeleton()
