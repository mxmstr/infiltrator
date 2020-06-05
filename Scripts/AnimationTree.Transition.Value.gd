extends 'res://AnimationTree.Transition.gd'

export(String) var transition_value

export(String, 'process', 'state_starting') var update_mode = 'process'

export(String, 'Equals', 'Not Equals', 'Greater Than', 'Less Than') var assertion = 'Equals'
export(String) var target
export(String) var method
export(Array) var args
export(float) var value
export(float) var wait_for_frame


func _evaluate(_value):
	
	var playback = owner.get(parameters + 'playback')
	
	var current_frame = 0 if not playback.is_playing() else playback.get_current_play_pos()
	
	if current_frame < wait_for_frame:
		return false
	
	match assertion:
		
		'Equals': return value == _value
		'Not Equals': return value != _value
		'Greater Than': return value < _value
		'Less Than': return value > _value


func _update():
	
	disabled = not _evaluate(owner.owner.get_node(target).callv(method, args))


func _on_state_starting(new_name):
	
	var from_name = parent.get_node_name(from)
	
	if from_name == new_name and update_mode == 'state_starting':
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