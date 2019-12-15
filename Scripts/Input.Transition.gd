extends AnimationNodeStateMachineTransition

enum Status {
	RELEASED,
	PRESSED,
	JUST_RELEASED,
	JUST_PRESSED
}

export(String) var action
export(Status) var state

var parent
var playback
var from
var to

var last_status = -1


func _ready(_parent, _playback, _from, _to):
	
	parent = _parent
	playback = _playback
	from = _from
	to = _to
	
	parent.connect('on_process', self, '_process')
	parent.connect('travel_starting', self, '_on_travel_starting')


func _process(delta):
	
	var mouse_device = parent.get_node('../Perspective').mouse_device
	var keyboard_device = parent.get_node('../Perspective').keyboard_device
	
	
	var status = RawInput._get_status(action, mouse_device, keyboard_device)
	
	disabled = not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status