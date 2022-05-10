extends 'res://Scripts/Input.Rotate.gd'

onready var bullet_time = $'../BulletTime'


func _get_aim_offset(delta):

	if owner.is_processing_input():

		var aim_offset = Vector2(0, (right.strength - left.strength) * aim_offset_range * (camera.fov / 65))
		aim_offset.y *= -1
		return  Vector2(0, camera_raycast.rotation_offset.y).linear_interpolate(
			aim_offset,
			aim_offset_sensitivity * delta
			).y

	else:

		return 0.0


func _process(delta):

	var scaled_delta = delta / Engine.time_scale if bullet_time.active else delta

	stance.look_speed = _get_rotation(scaled_delta) * 0.5
	camera_raycast.rotation_offset.y = _get_aim_offset(scaled_delta)
