extends 'res://Scripts/Input.Rotate.gd'

onready var bullet_time = $'../BulletTime'


func _get_aim_offset(delta):
	
	if owner.is_processing_input():

		var aim_offset = Vector2((-right.strength + left.strength) * aim_offset_range * (camera.fov / 65), 0)
		return Vector2(camera_raycast.rotation_offset.x, 0).linear_interpolate(
			aim_offset,
			aim_offset_sensitivity * delta
			).x

	else:

		return 0.0


func _process(delta):

	var scaled_delta = delta / Engine.time_scale if bullet_time.active else delta
	
	movement.angular_direction.x = -_get_rotation(delta)
	camera_raycast.rotation_offset.x = _get_aim_offset(delta)
