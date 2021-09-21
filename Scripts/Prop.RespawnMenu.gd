extends Control


func _just_pressed(event, action):
	
	return event.is_action(action) and \
		Input.is_action_just_pressed(action) and \
		event.device == owner.gamepad_device


func _input(event):
	
	if _just_pressed(event, 'ui_accept'):
		
		$'/root/Mission/Links/PVPPlayerFactory'._respawn(owner.owner)


func _ready():
	
	pass
