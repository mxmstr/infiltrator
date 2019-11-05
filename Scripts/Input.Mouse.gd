extends Node

export var sensitivity = 0.01

var active = true

onready var camera = owner.get_node('Perspective/Container/Viewport/CameraRig/Camera')


func _enter_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _leave_tree():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func mouse(offset):
	
	camera.rotation.x += offset.y * -sensitivity
	camera.rotation.y += offset.x * -sensitivity
	
	owner.rotation.y += offset.x * -sensitivity


func _process(delta):
	
	if not active: return
	
	var device = $'../Perspective'.mouse_device
	
	mouse(Inf._get_rawinput_mousemotion(device))
	
	Input.warp_mouse_position(Vector2(0.5, 0.5))
