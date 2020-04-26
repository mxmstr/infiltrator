extends 'res://Scripts/AnimationTree.gd'

var stims = []

var type
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

	var stim = stims.pop_front()

	type = stim[0]
	data = stim[1]

	emit_signal('on_stimulate', data.collider, data.position, data.normal, data.travel)

	._start_state(type, data)


func _contain():
	
	var link_data = {
		'from': owner.get_path(),
		'to': data.collider.get_path()
		}

	LinkHub._create('Contains', link_data)


func _reflect():
	
	if data == null:
		return
	
	if data.collider.has_node('Receptor'):
		
		var reflected = {
			'collider': data.collider,
			'position': data.position,
			'normal': data.normal * -1,
			'travel': data.travel * -1
			}

		data.collider.get_node('Receptor')._start_state(type, reflected)


func _ready():

	var playback = get('parameters/playback')

	tree_root.connect('state_starting', self, '_on_state_starting')