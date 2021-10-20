extends Node

export(String) var action
export var strength_multiplier = 1.0

var active
var strength
var last_status = -1

onready var perspective = get_node_or_null('../Perspective')


func _on_just_activated(): pass


func _on_active(): pass


func _on_just_deactivated(): pass


func _on_deactivated(): pass


func _input(event):
	
	if Meta.rawinput or not perspective:
		return
	
	
	if event.is_action(action) and event.device == perspective.gamepad_device:
		
		strength = event.get_action_strength(action)
		active = 1 if strength > 0 else 0
		strength *= strength_multiplier
		
		if active:
			
			if last_status != active:
				_on_just_activated()
			else:
				_on_active()
		
		else:
			
			_on_just_deactivated()
		
		last_status = active


func _process(delta):
	
	if not active:
		
		_on_deactivated()