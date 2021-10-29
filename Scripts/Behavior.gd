extends AnimationTree

var enable_abilities = true
var current_state = ''
var next = 'Default'
var switch_mode = 'Immediate'

var skeleton
var oneshot
var action

onready var animation_player = $AnimationPlayer

signal action


func _can_switch():
	
	return switch_mode == 'Immediate' or not _is_oneshot_active()


func _on_action_finished():
	
	if current_state == 'Default':
		return

	call_deferred('emit_signal', 'action', next, {})


func _start_state(_name, _data={}):
	
	if not enable_abilities:
		return
	
	emit_signal('action', _name, _data)


func _set_animation(animation, scale, clip_start, clip_end):
	
#	prints(animation, scale, clip_start, clip_end)
	
	action.scale = scale
	action.clip_start = clip_start
	action.clip_end = clip_end
	action.animation = animation


func _is_oneshot_active():
	
	return get('parameters/OneShot/active')


func _set_oneshot_active(enabled):
	
	set('parameters/OneShot/active', enabled)


func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	if not _can_switch():
		return false
	
	current_state = new_state
	
	_set_oneshot_active(false)
	advance(0)
	
	
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	next = 'Default'
	switch_mode = 'Immediate'
	
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
	
	_set_animation(animation, scale, clip_start, clip_end)
	
	
	if current_state == 'Default':
		return true
	
	_set_oneshot_active(true)
	
	return true


func _set_skeleton():
	
	if not has_node('../Model') or not $'../Model'.get_child_count():
		return
	
	
	var skeleton = $'../Model'.get_child(0)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(skeleton)


func _ready():
	
	_set_skeleton()
	
	tree_root = tree_root.duplicate(true)
	
	root_motion_track = NodePath('../../')
	
	skeleton = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	oneshot = tree_root.get_node('OneShot')
	action = tree_root.get_node('Action')
	
	oneshot.connect('finished', self, '_on_action_finished')
	
	active = true
	
	yield(get_tree(), 'idle_frame')
	
	emit_signal('action', 'Default', {})
	
