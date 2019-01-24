extends Node

export(NodePath) var interaction


func _ready():
	
	if interaction != null:
		get_node(interaction).enter()


func start_interaction(_name):
	
	get_node(interaction).exit()
	
	print(_name)
	var child = get_node(_name)
	child.enter()
	interaction = child.get_path()
