extends 'res://Scripts/AnimationTree.gd'

signal on_stimulate


func _start_state(_name, data={}):
	
	if not data.empty():
		emit_signal('on_stimulate', data.collider, data.position, data.normal, data.travel)
	
	._start_state(_name, data)
