extends "res://Scripts/Action.8Way.gd"

const test_off_wall_time = 0.25

var active = false
var test_off_wall = false
var x_min
var y_min
var x_value_range
var y_value_range

onready var behavior = $'../Behavior'
onready var movement = $'../Movement'
onready var stance = $'../Stance'
onready var camera_raycast = $'../CameraRaycastStim'


func _on_test_off_wall_timeout():
	
	if not owner.is_on_wall():
		
		stance.mode = stance.Mode.DEFAULT
		active = false
	
	test_off_wall = false


func _on_action(_state, _data):
	
	if _state == 'Dive':
		
		if not _play(_state, null):
			return
		
		data = _data


func _set_blendspace_position():
	
	var owner_rotation = owner.global_transform.basis.z
	var camera_rotation = -camera_raycast.global_transform.basis.z
	
	var facing_angle_x = camera_rotation.angle_to(
		owner_rotation.rotated(Vector3.UP, (PI / 2))
		)
	facing_angle_x = (PI / 2) - facing_angle_x
	
	var facing_angle_y = camera_rotation.angle_to(owner_rotation)
	facing_angle_y = (PI / 2) - facing_angle_y
	
	
	var x_value = facing_angle_x
	var x_max_value = 1
	var x_min_value = -1
	x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min
	
	var y_value = facing_angle_y
	var y_max_value = 1
	var y_min_value = -1
	y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min
	
	behavior.set('parameters/BlendSpace2D/blend_position', Vector2(x_value, y_value))


func _ready():
	
	yield(behavior, 'pre_advance')
	
	x_min = behavior.blend_space_2d.get('min_space').x
	y_min = behavior.blend_space_2d.get('min_space').y
	x_value_range = behavior.blend_space_2d.get('max_space').x - behavior.blend_space_2d.get('min_space').x
	y_value_range = behavior.blend_space_2d.get('max_space').y - behavior.blend_space_2d.get('min_space').y


func _process(delta):
	
	if behavior.current_state == 'Dive':
		
		_set_blendspace_position()
