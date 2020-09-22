extends 'res://Scripts/AnimationTree.gd'

var stims = []
var stim


func _collider_has_tag(tag):
	
	return data.collider._has_tag(tag)


func _on_tree_root_state_starting(sm_node_name):
	
	if sm_node_name == 'Default':

		if len(stims) == 0:
			pass#type = null
			#data = null
		else:
			_next_stim()


func _start_state(_name, _data={}):
	
	stims.append([_name, _data])

	if len(stims) == 1:
		_next_stim()


func _next_stim():

	var next_stim = stims.pop_front()

	var _stim = next_stim[0]
	var _data = next_stim[1]

	._start_state(_stim, _data)


func _link(type, reverse=false):
	
	if reverse:
		Meta.CreateLink(data.collider, owner, type)
	else:
		Meta.CreateLink(owner, data.collider, type)


func _reflect(reflected_stim=''):
	
	if data == null:
		return
	
	if reflected_stim == '':
		reflected_stim = stim
	
	Meta.StimulateActor(data.collider, reflected_stim, owner, data.position, data.direction * -1, data.intensity * -1)


func _ready():

	var playback = get('parameters/playback')

	tree_root.connect('state_starting', self, '_on_tree_root_state_starting')