extends Node

export(PackedScene) var source


func _ready():
	
#	if not owner.has_meta('unique'):
#		return
	
	
	for child in source.instance().get_child(0).get_children():
		
		get_node('../Model').get_child(0).add_child(child.duplicate())