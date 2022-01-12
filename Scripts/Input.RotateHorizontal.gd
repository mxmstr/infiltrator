extends "res://Scripts/Input.gd"

const aim_offset_range = 0.5
const aim_offset_sensitivity = 2.0

onready var movement = $'../Movement'
onready var camera = $'../CameraRig/Camera'
onready var camera_raycast = $'../CameraRaycastStim'
onready var stance = $'../Stance'


func _on_just_activated():
	
	stance._set_turn_speed(strength * Meta.rotate_sensitivity)


func _on_active():
	
	_on_just_activated()


func _process(delta):
	
	if owner.is_processing_input():
		
		var aim_offset = Vector2(strength * aim_offset_range * (camera.fov / 65), 0)
#		aim_offset.y *= -1
		camera_raycast.rotation_offset.x = Vector2(camera_raycast.rotation_offset.x, 0).linear_interpolate(
			aim_offset,
			aim_offset_sensitivity * delta
			).x
	
	else:
		
		camera_raycast.rotation_offset.x = 0
