extends Node

enum Status {
	RELEASED,
	PRESSED,
	JUST_RELEASED,
	JUST_PRESSED
}

export(String) var action
export(Status) var status
export var strength_multiplier = 1.0

var active
var strength
var last_status = -1

onready var perspective = get_node_or_null('../Perspective')


func _on_active(): pass


func _on_deactive(): pass


func _input(event):
	
	if Meta.rawinput or not perspective:
		return
	
	
	if event.is_action(action) and event.device == perspective.gamepad_device:
		
		strength = event.get_action_strength(action)
		var new_status = 1 if strength > 0 else 0
		
		active = (
			new_status == status \
			or (last_status != new_status and new_status + 2 == status)
			)
		
		
		if active:
			
#			owner.data['strength'] = strength * strength_multiplier
			_on_active()
		
		else:
			
			_on_deactive()
		
		last_status = new_status


func _process(delta):
	
	if not Meta.rawinput or not perspective:
		return

	var mouse_device = perspective.mouse_device
	var keyboard_device = perspective.keyboard_device
	var gamepad_device = perspective.gamepad_device


	var new_status = RawInput._get_status(action, mouse_device, keyboard_device)

	active = (
			new_status == status \
			or (last_status != new_status and new_status + 2 == status)
			)

	last_status = new_status
