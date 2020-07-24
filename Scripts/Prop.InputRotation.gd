extends 'res://Scripts/AnimationTree.gd'

export var sensitivity = 0.01


func _enter_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _leave_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func mouse(offset):
	
	$'../CameraRig'._rotate_camera(offset.y * -sensitivity, offset.x * -sensitivity)
	$'../Movement'._turn(offset.x * -sensitivity)


func _process(delta):
	
	var device = $'../Perspective'.mouse_device
	
	mouse(RawInput._get_mousemotion(device))
	
	Input.warp_mouse_position(Vector2(0.5, 0.5))
