extends Node

@export var tree: NodePath

func _enter_tree():
	
	for child in get_children():
		
		if not child.tree:
			child.tree = NodePath('../' + str(tree))
		
		child.set_owner(owner)
