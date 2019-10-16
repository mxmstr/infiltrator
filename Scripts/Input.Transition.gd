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
var last_status = -1


func _init(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, '_process')


func _process(delta):
	
	var mouse_device = parent.get_node('../PlayerControl').mouse_device
	var keyboard_device = parent.get_node('../PlayerControl').keyboard_device
	
	
	var pressed = true
	var status = Inf._get_rawinput_status(action, mouse_device, keyboard_device)
	
	
	disabled = not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status