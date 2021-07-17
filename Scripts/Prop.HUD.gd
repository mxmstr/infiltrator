extends Control

export(NodePath) var viewport


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		pass#set_viewport(get_node(viewport))


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	#set_viewport(get_node(viewport))


func _process(delta):
	
	pass#print(get_node(viewport), ' ', get_viewport())
