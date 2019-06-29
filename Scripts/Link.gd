extends Node

export var enabled = true
export(NodePath) var from
export(NodePath) var to
#export var from = [NodePath()]
#export var to = [NodePath()]


func _ready():
	
	if enabled:
		_on_enter()
	else:
		set_process(false)


func _on_enter(): pass


func _on_execute(): pass


func _on_exit(): pass


func _process(delta):
	
	_on_execute()
