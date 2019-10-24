extends AnimationNodeStateMachineTransition

export(String, 'Equals', 'Greater Than', 'Less Than') var assertion = 'Equals'
export(String) var target
export(String) var method
export(float) var value
export(float) var wait_for_frame

var parent
var from
var to


func _evaluate(_value):
	
	var playback = parent.get('parameters/playback')
	
	if playback.get_current_play_pos() < wait_for_frame:
		return false
	
	match assertion:
		
		'Equals': return value == _value
		'Greater Than': return value >= _value
		'Less Than': return value <= _value


func _ready(_parent, _from, _to):
	
	parent = _parent
	from = _from
	to = _to
	
	parent.connect('on_process', self, '_process')


func _process(delta):
	
	disabled = not _evaluate(parent.get_parent().get_node(target).call(method))