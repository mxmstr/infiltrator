extends Node


func enable():
	
	for child in get_children():
		child.enable()


func disable():
	
	for child in get_children():
		child.disable()
