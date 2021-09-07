extends AnimationNodeStateMachineTransition

enum Status {
	RELEASED,
	PRESSED,
	JUST_RELEASED,
	JUST_PRESSED
}

export(String) var action
export(Status) var status
export var strength_multiplier = 1.0

var owner
var parent
var parameters
var connections = []
var from
var to

var perspective
var last_status = -1


func _input(event):
	
	if Meta.rawinput or not perspective:
		return
	
	
	if event.is_action(action) and event.device == perspective.gamepad_device:
		
		var strength = event.get_action_strength(action)
		var new_status = 1 if strength > 0 else 0
		
		disabled = not (
			new_status == status \
			or (last_status != new_status and new_status + 2 == status)
			)
		
#		if owner.name == 'PrimaryActionInput' and not disabled:
#			prints('asdf')
		
		
		if not disabled:
			
			owner.data['strength'] = strength * strength_multiplier
#			owner.advance(0.01)
		
		last_status = new_status


func _ready(_owner, _parent, _parameters, _from, _to):
	
	owner = _owner
	parent = _parent
	parameters = _parameters
	from = _from
	to = _to
	
	perspective = owner.get_node_or_null('../Perspective')
	
	owner.connect('on_process', self, '_process')
	owner.connect('on_input', self, '_input')


func _process(delta):
	
	if not Meta.rawinput or not perspective:
		return
	
	var mouse_device = perspective.mouse_device
	var keyboard_device = perspective.keyboard_device
	var gamepad_device = perspective.gamepad_device
	
	
	var new_status = RawInput._get_status(action, mouse_device, keyboard_device)
	
	disabled = not (
			new_status == status \
			or (last_status != new_status and new_status + 2 == status)
			)
	
	last_status = new_status
