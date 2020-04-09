extends Control

export(NodePath) var viewport


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		set_viewport(get_node(viewport))