extends AnimationNodeStateMachineTransition

export(String, 'True', 'False', 'Null', 'NotNull') var assertion = 'True'
export(String) var target
export(String) var method
export(Array) var args
export(float) var wait_for_frame

var owner
var parent
var parameters
var from
var to


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


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	disabled = not _evaluate(owner.owner.get_node(target).callv(method, args))