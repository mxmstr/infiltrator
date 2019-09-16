extends Node

onready var parent = $'../../'


func enable():
	
	set_process(true)
	set_physics_process(true)
	set_process_input(true)


func disable():
	
	set_process(false)
	set_physics_process(false)
	set_process_input(false)


func _physics_process(delta):
	
	var direction = Vector3()
	var cam_xform = parent.global_transform
	
	var directions = { 
		'Forward':  cam_xform.basis.z, 
		'Backward': -cam_xform.basis.z, 
		'Left': cam_xform.basis.x, 
		'Right': -cam_xform.basis.x 
		}
	
	
	for action in directions:
		
		var status = Inf._get_rawinput_status(action, get_parent().mouse_device, get_parent().keyboard_device)
		
		if status == 1:
			direction += directions[action]
			break
	
	
	direction.y = 0
	parent.get_node('HumanMovement').direction = direction.normalized()
