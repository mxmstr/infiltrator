extends 'res://Scripts/AnimationTree.gd'

var stims = []

var stim
var data

signal on_stimulate


func _on_state_starting(new_node):

	if new_node == 'Default':

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

	stim = next_stim[0]
	data = next_stim[1]

	emit_signal('on_stimulate', data.collider, data.position, data.direction, data.intensity)

	._start_state(stim, data)


func _link(type):
	
	Meta.CreateLink(owner, data.collider, type)


func _reflect(reflected_stim=''):
	
	if data == null:
		return
	
	if reflected_stim == '':
		reflected_stim = stim
	
	Meta.StimulateActor(data.collider, reflected_stim, owner, data.position, data.direction * -1, data.intensity * -1)


func _ready():

	var playback = get('parameters/playback')

	tree_root.connect('state_starting', self, '_on_state_starting')