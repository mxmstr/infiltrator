extends Node

export(String) var action
export var strength_multiplier = 1.0

var active = 0
var strength = 0
var last_status = -1

onready var perspective = get_node_or_null('../Perspective')

signal just_activated
signal active
signal just_deactivated
signal deactivated


func _on_just_activated(): pass


func _on_active(): pass


func _on_just_deactivated(): pass


func _on_deactivated(): pass


func _input(event):
	
	if not owner.is_processing_input() or Meta.rawinput or not perspective:
		return
	
	
	if event.is_action(action) and event.device == perspective.gamepad_device:
		
		strength = event.get_action_strength(action)
		
		active = 1 if strength > 0 else 0
		strength *= strength_multiplier
		
		if active:
			
			if last_status != active:
				_on_just_activated()
				emit_signal('just_activated')
			else:
				_on_active()
				emit_signal('active')
		
		else:
			
			_on_just_deactivated()
			emit_signal('just_deactivated')
		
		last_status = active


func _process(delta):
	
	if not owner.is_processing_input():
		return
	
	if not active:
		
		_on_deactivated()
		emit_signal('deactivated')
