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

var anim_name
var parent
var trigger = true
var events
var last_status = -1


func _on_target_signal(value):
	
	match assertion:
		
		'True':
			trigger = value
		'False':
			trigger = not value
		'Null':
			trigger = value == null
		'NotNull':
			trigger = value != null


func init(_parent, _anim_name):
	
	anim_name = _anim_name
	parent = _parent
	
	parent.connect('on_process', self, 'process')
	
	
	events = InputMap.get_action_list(action)


func process():
	
	if assertion != 'None':
		_on_target_signal(parent.get_parent().get_node(target).call(method))
	
	
	var pressed = true
	var status = Inf._get_rawinput_status(action, parent.mouse_device, parent.keyboard_device)
	
	
	#print(status, ' ', state) if action == 'Run' else null
	
	disabled = not trigger \
		or not (
			status == state \
			or (last_status != status and status + 2 == state)
			)
	
	last_status = status