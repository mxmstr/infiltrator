extends Node

onready var parent = $'../../../'

export var sensitivity = 0.002


func _enter_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _leave_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func enable():
	
	set_process_input(true)


func disable():
	
	set_process_input(false)


func look_updown_rotation(rotation=0):
	
	var toReturn = parent.get_node('PlayerControl/Viewport/Camera').rotation + Vector3(rotation, 0, 0)
	toReturn.x = clamp(toReturn.x, PI / -2, PI / 2)
	
	return toReturn


func look_leftright_rotation(rotation=0):
	
	return parent.rotation + Vector3(0, rotation, 0)


func mouse(event):
	
	parent.get_node('PlayerControl/Viewport/Camera').set_rotation(look_updown_rotation(event.relative.y * -sensitivity))
	parent.set_rotation(look_leftright_rotation(event.relative.x * -sensitivity))


func _input(event):
	
	if event is InputEventMouseMotion:
		return mouse(event)


func _process(delta):
	
	Input.warp_mouse_position(Vector2(0.5, 0.5))