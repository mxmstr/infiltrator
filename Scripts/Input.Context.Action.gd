extends Node

export(String) var action_name
export(float) var release_delay
export(Dictionary) var on_just_pressed = {'target': '', 'method': '', 'args': []}
export(Dictionary) var on_pressed = {'target': '', 'method': '', 'args': []}
export(Dictionary) var on_just_released = {'target': '', 'method': '', 'args': []}
export(Dictionary) var on_released = {'target': '', 'method': '', 'args': []}

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
	
	var signal_params = get(action).duplicate(true)
	
	if '' in [signal_params['target'], signal_params['method']]:
		return
	
	var target = actor.get_node(signal_params['target'])

	connect(action, target, signal_params['method'], signal_params['args'])


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