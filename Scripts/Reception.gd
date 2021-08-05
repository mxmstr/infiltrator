extends 'res://Scripts/AnimationTree.gd'

var stims = []
var stim


func _on_tree_root_pre_process():
	
	if data and not weakref(data.source).get_ref():
		_next_stim()


func _on_tree_root_post_process():
	
	pass


func _on_tree_root_state_starting(sm_node_name):
	
	pass


func _start_state(_name, _data={}):
	
	if not active:
		return
	
	stims.append([_name, _data])

	if len(stims) == 1:
		_next_stim()


func _next_stim():
	
	if not stims.size():
		
		stim = null
		data = null
		
		return
	
	var next_stim = stims.pop_front()
	
	stim = next_stim[0]
	data = next_stim[1]
	
	if tree_root.has_method('_start'):
		tree_root._start(stim)


func _reflect(reflected_stim=''):
	
	if not data:
		return
	
	if reflected_stim == '':
		reflected_stim = stim
	
	Meta.StimulateActor(data.source, reflected_stim, owner, data.intensity * -1, data.position, data.direction * -1)


func _ready():
	
	var playback = get('parameters/playback')
	playback.connect('state_starting', self, '_on_tree_root_state_starting')
	playback.connect('pre_process', self, '_on_tree_root_pre_process')
	playback.connect('post_process', self, '_on_tree_root_post_process')
