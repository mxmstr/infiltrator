extends Node

export(String) var action_name
export(Array, Array, String) var on_just_pressed
export(Array, Array, String) var on_pressed
export(Array, Array, String) var on_just_released

signal on_just_pressed
signal on_pressed
signal on_just_released


func enable():
	
	set_process_input(true)


func disable():
	
	set_process_input(false)


func _connect_signals(action):
	
	var signals = action.duplicate()
	
	for sig_params in signals:
		
		if len(sig_params) < 2:
			continue
		
		var target = get_node(sig_params[0])
		var method = sig_params[1]
		
		sig_params.pop_front()
		sig_params.pop_front()
		var args = sig_params
		
		connect('on_just_pressed', target, method, args)


func _ready():
	
	for action in [on_just_pressed, on_pressed, on_just_released]:
		_connect_signals(action)


func _input(event):
	
#	if event is InputEventAction and \
#		event.action == action_name and \
#		event.device == $'../../'.device:
		
	if Input.is_action_just_pressed(action_name):
		emit_signal('on_just_pressed')
	elif Input.is_action_pressed(action_name):
		emit_signal('on_pressed')
	elif Input.is_action_just_released(action_name):
		emit_signal('on_just_released')