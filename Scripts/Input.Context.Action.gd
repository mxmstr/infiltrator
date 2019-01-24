extends Node

export(String) var action_name

signal on_just_pressed
signal on_pressed
signal on_just_released


func enable():
	
	set_process(true)


func disable():
	
	set_process(false)


func _ready():
	
	pass


func _process(delta):
	
	if Input.is_action_just_pressed(action_name):
		emit_signal('on_just_pressed')
	elif Input.is_action_pressed(action_name):
		emit_signal('on_pressed')
	elif Input.is_action_just_released(action_name):
		emit_signal('on_just_released')