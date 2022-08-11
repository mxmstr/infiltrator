extends Node#'res://Scripts/AnimationTree.gd'

var stims = []
var stim
var data = {}
var last_node

signal stimulate
signal tree_root_state_started


func _on_tree_root_pre_process():
	
	if data.has('source') and not is_instance_valid(data.source):
		_next_stim()


func _on_tree_root_post_process():
	
	pass


func _on_tree_root_state_starting(sm_node_name):
	
	
	emit_signal('tree_root_state_started', sm_node_name)


func _start_state(_name, _data={}):
	
	stim = _name
	data = _data
	
	emit_signal('stimulate', stim, data)
	
#	if not active:
#		return
	
#	stims.append([_name, _data])
#
##	if len(stims) == 1:
#	_next_stim()


func _next_stim():
	
	if not stims.size():
		
#		stim = null
#		data = {}
		
		return
	
	var next_stim = stims.pop_front()
	
	stim = next_stim[0]
	data = next_stim[1]
	
	emit_signal('stimulate', stim, data)
	
	_next_stim()
	
#	if tree_root.has_method('_start'):
#		tree_root._start(stim)


func _reflect(reflected_stim=''):
	
#	prints(owner.name, 'reflect', reflected_stim)
	
	if not data:
		return
	
	if reflected_stim == '':
		reflected_stim = stim
	
	ActorServer.Stim(data.source, reflected_stim, owner, data.intensity, data.position, data.direction * -1)


#func _ready():
#
#	var playback = get('parameters/playback')
#	playback.connect('state_starting', self, '_on_tree_root_state_starting')
#	playback.connect('pre_process', self, '_on_tree_root_pre_process')
#	playback.connect('post_process', self, '_on_tree_root_post_process')


#func _process(delta):
#
#	var playback = get('parameters/playback')
#	var current_node = playback.get_current_node()
	
#	if 'Anderson' in owner.name and current_node != last_node:
#		prints(OS.get_system_time_msecs(), current_node)
#		last_node = current_node
