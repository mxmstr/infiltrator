extends Node

export var sensitivity = 0.01

var active = true


func _enter_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _leave_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func look_updown_rotation(rotation=0):
	
	var toReturn = owner.get_node('Perspective/Container/Viewport/CameraRig/Camera').rotation + Vector3(rotation, 0, 0)
	toReturn.x = clamp(toReturn.x, PI / -2, PI / 2)
	
	return toReturn


func look_leftright_rotation(rotation=0):
	
	return owner.rotation + Vector3(0, rotation, 0)


func mouse(offset):
	
	owner.get_node('Perspective/Container/Viewport/CameraRig/Camera').set_rotation(look_updown_rotation(offset.y * -sensitivity))
	owner.set_rotation(look_leftright_rotation(offset.x * -sensitivity))


func _input(event):
	
	pass
#	if event is InputEventMouseMotion:
#		return mouse(event)


func _process(delta):
	
	if not active: return
	
	var device = $'../Perspective'.mouse_device
	
	mouse(Inf._get_rawinput_mousemotion(device))
	Input.warp_mouse_position(Vector2(0.5, 0.5))
