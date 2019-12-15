extends Node



func _physics_process(delta):
	
	if not owner.active:
		return
	
	var perspective = $'../../Perspective'
	var human_movement = $'../../HumanMovement'
	
	var mouse_device = perspective.mouse_device
	var keyboard_device = perspective.keyboard_device
	
	var direction = Vector3()
	var directions = { 
		'Forward':  Vector3(0, 0, 1), 
		'Backward': Vector3(0, 0, -1), 
		'Left': Vector3(1, 0, 0), 
		'Right': Vector3(-1, 0, 0)
		}
	
	
	for action in directions:
		
		var status = RawInput._get_status(action, mouse_device, keyboard_device)
		
		if status == 1:
			direction += directions[action]
	
	human_movement._set_direction(direction.normalized())
