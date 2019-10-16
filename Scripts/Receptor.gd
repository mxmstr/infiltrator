extends 'res://Scripts/StateMachine.gd'

signal on_stimulate


func _start_state(_name, data={}):
	
	emit_signal('on_stimulate', data.collider, data.position, data.normal, data.travel)
	
	._start_state(_name, data)