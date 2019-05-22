extends Node

enum status {
	OPEN, 
	CLOSED, 
	OPENING,
	CLOSING,
	BLOCKED
}

export(status) var current_status
export(Vector3) var closed_position
export(Vector3) var open_position
export(Vector3) var closed_angle
export(Vector3) var open_angle
export(bool) var direction
export(float) var speed
export(int, FLAGS, 'X', 'Y', 'Z') var axis
export(float) var block_sound_percent
export(float) var max_push_mass


func _set_status(new_status):
	
	current_status = status[new_status]


func _ready():
	
	pass


func _process(delta):
	
	match current_status:
		
		status.OPEN:
			
			get_parent().translation = open_position
			get_parent().rotation_degrees = open_angle
			
		status.CLOSED:
			
			get_parent().translation = closed_position
			get_parent().rotation_degrees = closed_angle
			
		status.OPENING:
			
			get_parent().translation = get_parent().translation.linear_interpolate(open_position, speed * delta)
			get_parent().rotation_degrees = get_parent().rotation_degrees.linear_interpolate(open_angle, speed * delta)

			if (get_parent().translation - open_position).length() < 0.001 and \
				get_parent().rotation_degrees.angle_to(open_angle) < 1.0: 
				current_status = status.OPEN
			
		status.CLOSING:
			
			get_parent().translation = get_parent().translation.linear_interpolate(closed_position, speed * delta)
			get_parent().rotation_degrees = get_parent().rotation_degrees.linear_interpolate(closed_angle, speed * delta)

			if (get_parent().translation - closed_position).length() < 0.01 and \
				get_parent().rotation_degrees.angle_to(closed_angle) < 1.0: 
				current_status = status.CLOSED
			
		status.BLOCKED: pass
