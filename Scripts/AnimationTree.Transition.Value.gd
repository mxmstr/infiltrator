extends AnimationNodeStateMachineTransition

export(String, 'Equals', 'Not Equals', 'Greater Than', 'Less Than') var assertion = 'Equals'
export(String) var target
export(String) var method
export(Array) var args
export(float) var value
export(float) var wait_for_frame

var parent
var parameters
var from
var to


func _evaluate(_value):
	
	var playback = parent.get(parameters + 'playback')
	
	var current_frame = 0 if not playback.is_playing() else playback.get_current_play_pos()
	
	if current_frame < wait_for_frame:
		return false
	
	match assertion:
		
		'Equals': return value == _value
		'Not Equals': return value != _value
		'Greater Than': return value >= _value
		'Less Than': return value <= _value


func _ready(_parent, _parameters, _from, _to):
	
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	parent.connect('on_process', self, '_process')


func _process(delta):
	
	disabled = not _evaluate(parent.owner.get_node(target).callv(method, args))