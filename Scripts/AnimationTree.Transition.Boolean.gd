extends 'res://AnimationTree.Transition.gd'

export(String) var transition_boolean

export(String, 'process', 'state_starting') var update_mode = 'process'

export(String, 'True', 'False', 'Null', 'NotNull') var assertion = 'True'
export(String) var target
export(String) var method
export(Array) var args
export(float) var wait_for_frame


func _evaluate(value):
	
	var playback = owner.get(parameters + 'playback')
	
	var current_frame = 0 if not playback.is_playing() else playback.get_current_play_pos()
	
	if current_frame < wait_for_frame:
		return false
	
	match assertion:

		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func _update():
	
	disabled = not _evaluate(owner.owner.get_node(target).callv(method, args))


func _on_state_starting(new_name):

	if from.get('node_name') == null:
		return
	
	if from.node_name == new_name and update_mode == 'state_starting':
		_update()


func _ready(_owner, _parent, _parameters, _from, _to):
	
	._ready(_owner, _parent, _parameters, _from, _to)
	
	if parent != null and owner.get(parent.parameters + 'playback') != null:
		owner.get(parent.parameters + 'playback').connect('state_starting', self, '_on_state_starting')
	
	parent.connect('state_starting', self, '_on_state_starting') if parent != null else null
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	if update_mode == 'process':
		_update()
