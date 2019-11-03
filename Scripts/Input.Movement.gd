extends Node


func _physics_process(delta):
	
	if not get_parent().active:
		return
	
	var mouse_device = $'../../Perspective'.mouse_device
	var keyboard_device = $'../../Perspective'.keyboard_device
	
	var direction = Vector3()
	var cam_xform = $'../../'.global_transform
	
	var directions = { 
		'Forward':  cam_xform.basis.z, 
		'Backward': -cam_xform.basis.z, 
		'Left': cam_xform.basis.x, 
		'Right': -cam_xform.basis.x 
		}
	
	
	for action in directions:
		
		var status = Inf._get_rawinput_status(action, mouse_device, keyboard_device)
		
		if status == 1:
			direction += directions[action]
	
	direction.y = 0
	
	$'../../'.get_node('HumanMovement').direction = direction.normalized()
