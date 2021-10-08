extends Node

export(NodePath) var tree_node


func _ready():
	
	if tree_node.is_empty():
		return
	
	get_node(tree_node).connect('stimulate', self, '_on_stimulate')


func _on_stimulate(stim, data): pass