extends Node

#enum status {
#	OPEN, 
#	CLOSED, 
#	OPENING,
#	CLOSING,
#	BLOCKED
#}
#
#@export var current_status: status
#@export var closed_position: Vector3
#@export var open_position: Vector3
#@export var closed_angle: Vector3
#@export var open_angle: Vector3
#@export var direction: bool
#@export var speed: float
#@export var axis # (int, FLAGS, 'X', 'Y', 'Z')
#@export var block_sound_percent: float
#@export var max_push_mass: float
#
#
#func _set_status(new_status):
#
#	current_status = status[new_status]
#
#
#func _move_to(delta, new_position):
#
#	var distance = get_parent().position.distance_to(new_position)
#	var direction = get_parent().position.direction_to(new_position)
#	direction *= speed * delta
#
#	if direction.length() > 0:
#		get_parent().global_translate(direction)
#
#	var new_distance = get_parent().position.distance_to(new_position)
#
#	if new_distance > distance:
#		get_parent().position = new_position
#		return true
#
#	return false
#
#
#func _rotate_to(delta, new_angle):
#
#	var distance = get_parent().rotation_degrees.distance_to(new_angle)
#	var direction = get_parent().rotation_degrees.direction_to(new_angle)
#
#	if direction.length() > 0:
#		get_parent().global_rotate(direction, speed * delta)
#
#	var new_distance = get_parent().rotation_degrees.distance_to(new_angle)
#
#	if new_distance > distance:
#		get_parent().rotation_degrees = new_angle
#		return true
#
#	return false
#
#
#func _ready():
#
#	pass
#
#
#func _physics_process(delta):
#
#	match current_status:
#
#		status.OPEN:
#
#			get_parent().position = open_position
#			get_parent().rotation_degrees = open_angle
#
#		status.CLOSED:
#
#			get_parent().position = closed_position
#			get_parent().rotation_degrees = closed_angle
#
#		status.OPENING:
#
#			var moved = _move_to(delta, open_position)
#			var rotated = _rotate_to(delta, open_angle)
#
#			if moved and rotated:
#				current_status = status.OPEN
#
#		status.CLOSING:
#
#			var moved = _move_to(delta, closed_position)
#			var rotated = _rotate_to(delta, closed_angle)
#
#			if moved and rotated:
#				current_status = status.CLOSED
#
#		status.BLOCKED: pass
