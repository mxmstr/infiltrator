extends AnimationNodeStateMachineTransition

export(String) var action
export(String, 'just_pressed', 'pressed', 'just_released', 'released') var state = 'just_pressed'
export(String, 'None', 'True', 'False', 'Null', 'NotNull') var assertion = 'None'
export(String) var target
export(String) var method

var anim_name
var parent
var trigger = true


func on_target_signal(value):
	
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


func process():
	
	if assertion != 'None':
		on_target_signal(parent.get_parent().get_node(target).call(method))
	
	
	var pressed = true
	
	if state == 'released':
		for s in ['just_pressed', 'pressed', 'just_released']:
			if Input.call('is_action_' + s, action):
				pressed = false
	else:
		pressed = Input.call('is_action_' + state, action)
	
	
	disabled = not trigger or not pressed