extends Node

export(String) var action_name
export(float) var release_delay
export(Array, Array, String) var on_just_pressed
export(Array, Array, String) var on_pressed
export(Array, Array, String) var on_just_released
export(Array, Array, String) var on_released

signal on_just_pressed
signal on_pressed
signal on_just_released
signal on_released

onready var actor = owner.get_parent()


func enable():
	
	set_process(true)
	set_process_input(true)
	
	_enable_children()


func _enable_children():
	
	for child in get_children():
		child.enable() if child.has_method('enable') else null


func disable():
	
	set_process(false)
	set_process_input(false)
	
	$Timer.queue_free() if has_node('Timer') else null
	_disable_children()


func _disable_children():
	
	for child in get_children():
		child.disable() if child.has_method('disable') else null


func _connect_signals(action):
	
	var signals = get(action).duplicate(true)
	
	for sig_params in signals:
		
		if len(sig_params) < 2:
			continue
		
		var target = actor.get_node(sig_params[0])
		var method = sig_params[1]

		sig_params.pop_front()
		sig_params.pop_front()
		var args = sig_params

		connect(action, target, method, args)


func _on_timeout():
	
	_enable_children()
	
	$Timer.queue_free()


func _start_timer():
	
	var timer = Timer.new()
	timer.name = 'Timer'
	timer.autostart = true
	timer.wait_time = release_delay
	timer.connect('timeout', self, '_on_timeout')
	add_child(timer)


func _ready():
	
	for action in ['on_just_pressed', 'on_pressed', 'on_just_released']:
		_connect_signals(action)


func _input(event):
	
#	if event is InputEventAction and \
#		event.action == action_name and \
#		event.device == $'../../'.device:
	pass


func _process(delta):
	
	if Input.is_action_just_pressed(action_name):
		emit_signal('on_just_pressed')
		_disable_children()
	elif Input.is_action_pressed(action_name):
		emit_signal('on_pressed')
	elif Input.is_action_just_released(action_name):
		emit_signal('on_just_released')
		_enable_children() if release_delay == 0 else _start_timer()
	else:
		emit_signal('on_released')