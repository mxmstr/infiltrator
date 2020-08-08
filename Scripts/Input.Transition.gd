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
var parameters
var connections = []
var from
var to

var last_status = -1


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	owner.connect('on_process', self, '_process')


func _process(delta):
	
	if not owner.has_node('../Perspective'):
		return
	
	var mouse_device = owner.get_node('../Perspective').mouse_device
	var keyboard_device = owner.get_node('../Perspective').keyboard_device
	
	
	var status = RawInput._get_status(action, mouse_device, keyboard_device)
	
	disabled = not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status
