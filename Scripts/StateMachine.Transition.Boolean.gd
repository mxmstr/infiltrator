extends AnimationNodeStateMachineTransition

export(String, 'True', 'False', 'Null', 'NotNull') var assertion = 'True'
export(String) var target
export(String) var method
export(Array) var args
export(float) var wait_for_frame

var parent
var playback
var from
var to


func _evaluate(value):
	
	var current_frame = 0 if not playback.is_playing() else playback.get_current_play_pos()
	
	if current_frame < wait_for_frame:
		return false
	
	match assertion:

		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func _ready(_parent, _playback, _from, _to):
	
	parent = _parent
	playback = _playback
	from = _from
	to = _to
	
	parent.connect('on_process', self, '_process')


func _process(delta):
	
	disabled = not _evaluate(parent.owner.get_node(target).callv(method, args))