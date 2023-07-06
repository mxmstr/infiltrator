extends Node

var tree_node


func _ready():
	
	tree_node = get_parent()
	tree_node.connect('stimulate',Callable(self,'_on_stimulate'))


func _on_stimulate(stim, data): pass
