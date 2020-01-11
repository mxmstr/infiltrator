extends AnimationNodeStateMachineTransition

enum Status {
	RELEASED,
	PRESSED,
	JUST_RELEASED,
	JUST_PRESSED
}

export(String) var action
export(Status) var state

var owner
var parent
var playback
var from
var to

var last_status = -1


func _ready(_owner, _parent, _playback, _from, _to):
	
	owner = _owner
	parent = _parent
	playback = _playback
	from = _from
	to = _to
	
	owner.connect('on_process', self, '_process')
	owner.connect('travel_starting', self, '_on_travel_starting')


func _process(delta):
	
	var mouse_device = owner.get_node('../Perspective').mouse_device
	var keyboard_device = owner.get_node('../Perspective').keyboard_device
	
	
	var status = RawInput._get_status(action, mouse_device, keyboard_device)
	
	disabled = not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status