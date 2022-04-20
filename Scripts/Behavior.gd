extends Node

export var default_state = 'Default'

var enable_abilities = true
var current_state = 'Default'
var next = 'Default'
var switch_mode = 'Immediate'
var clip_start = 0
var clip_end = 0
var scale = 1.0
var priority = 0
var endless = false
var finished = true

var skeleton

onready var model = get_node_or_null('../Model')

signal action


func _is_action_playing():
	
	return call('is_playing')


func _can_switch(new_priority, override):
	
	return override or \
		not _is_action_playing() or \
		new_priority > priority or \
		(new_priority == priority and switch_mode == 'Immediate')


func _on_action_finished(animation_name=null):
	
	finished = true
	
	if endless:
		return
	
	call_deferred('emit_signal', 'action', next, {})


func _start_state(_name, _data={}):
	
	if not enable_abilities:
		return
	
	emit_signal('action', _name, _data)


func _add_animation(animation_name, animation_res):
	
	call('add_animation', animation_name, animation_res)


func _set_animation(animation, scale, clip_start, clip_end):
	
	call('play', animation, -1, scale)


func _apply_attributes(new_state, attributes):
	
	var override = attributes.has('override')
	var new_priority = attributes.priority if attributes.has('priority') else 0
	
	if not _can_switch(new_priority, override):
		return false
	
	current_state = new_state
	
	clip_start = 0
	clip_end = 0
	scale = 1.0
	next = 'Default'
	switch_mode = 'Immediate'
	priority = new_priority
	endless = false
	finished = false
	
	if attributes.has('speed'):
		scale = attributes.speed
	
	if attributes.has('clip_start'):
		clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		clip_end = attributes.clip_end
	
	if attributes.has('next'):
		next = attributes.next
	
	if attributes.has('switch_mode'):
		switch_mode = attributes.switch_mode
	
	if attributes.has('endless'):
		endless = attributes.endless
	
	return true


func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	if not _apply_attributes(new_state, attributes):
		return false
	
	if current_state == 'Default':
		return true
	
	_set_animation(animation, scale, clip_start, clip_end)
	
	return true


func _set_skeleton():
	
	if model and model.get_child_count():
		
		skeleton = model.get_child(0)
		set('root_node', get_path_to(skeleton))
	
	connect('animation_finished', self, '_on_action_finished')


func _ready():
	
	yield(get_tree(), 'idle_frame')
	
	_set_skeleton()
	
	call_deferred('emit_signal', 'action', default_state, {})
