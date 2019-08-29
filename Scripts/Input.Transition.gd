extends AnimationNodeStateMachineTransition

export(String, 'just_pressed', 'pressed', 'just_released', 'released') var state = 'just_pressed'
export(String, 'None', 'True', 'False', 'Null', 'NotNull') var assertion = 'None'
export(String) var target
export(String) var signal_name

var anim_name
var trigger = true


func on_target_signal(value):
	
	match assertion:
		
		'True':
			trigger = not value
		'False':
			trigger = value
		'Null':
			trigger = value != null
		'NotNull':
			trigger = value == null


func init(parent, _anim_name):
	
	anim_name = _anim_name
	
	parent.connect('on_process', self, 'process')
	
	if assertion != 'None':
		parent.get_node(target).connect(signal_name, self, 'on_target_signal')


func process():
	
	var pressed = true
	
	if state == 'released':
		for s in ['just_pressed', 'pressed', 'just_released']:
			if Input.call('is_action_' + s, anim_name):
				pressed = false
	else:
		pressed = Input.call('is_action_' + state, anim_name)
	
	disabled = not trigger or not pressed