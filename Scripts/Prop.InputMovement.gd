extends 'res://Scripts/AnimationTree.gd'


func _physics_process(delta):
	
	var perspective = $'../Perspective'
	var human_movement = $'../Movement'
	
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
