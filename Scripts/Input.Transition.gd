extends AnimationNodeStateMachineTransition

enum Status {
	RELEASED,
	PRESSED,
	JUST_RELEASED,
	JUST_PRESSED
}

export(String) var action
export(Status) var state
export(String, 'None', 'True', 'False', 'Null', 'NotNull') var assertion = 'None'
export(String) var target
export(String) var method

var parent
var last_status = -1


func _on_target_signal(value):
	
	match assertion:
		
		'True': return value
		'False': return not value
		'Null': return value == null
		'NotNull': return value != null


func init(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, 'process')


func process():
	
	var mouse_device = parent.get_node('../PlayerControl').mouse_device
	var keyboard_device = parent.get_node('../PlayerControl').keyboard_device
	
	
	var trigger = true
	
	if assertion != 'None':
		_on_target_signal(parent.get_parent().get_node(target).call(method))
	
	
	var pressed = true
	var status = Inf._get_rawinput_status(action, mouse_device, keyboard_device)
	
	
	disabled = not trigger \
		or not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status