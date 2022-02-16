extends "res://Scripts/Input.gd"

const aim_offset_range = 0.9
const aim_offset_sensitivity = 2.0

onready var movement = $'../Movement'
onready var camera = $'../CameraRig/Camera'
onready var camera_raycast = $'../CameraRaycastStim'
onready var stance = $'../Stance'


func _on_just_activated():
	
	stance._set_look_speed(strength * Meta.rotate_sensitivity)


func _on_active():
	
	_on_just_activated()


func _process(delta):
	
	var scaled_delta = delta / Engine.time_scale if bullet_time.active else delta
	
	if owner.is_processing_input():
		
		var aim_offset = Vector2(0, strength * aim_offset_range * (camera.fov / 65))
		aim_offset.y *= -1
		camera_raycast.rotation_offset.y = Vector2(0, camera_raycast.rotation_offset.y).linear_interpolate(
			aim_offset,
			aim_offset_sensitivity * scaled_delta
			).y
	
	else:
		
		camera_raycast.rotation_offset.y = 0
