extends 'res://Scripts/Action.gd'

export(float) var level


func _start():
	
	tree_node.get_node('AudioStreamPlayer3D').level = level
	
	._start()
