extends "res://Scripts/Action.gd"

var x_min
var y_min
var x_value_range
var y_value_range

@onready var model = $'../../Model'
@onready var movement = $'../../Movement'
@onready var stance = $'../../Stance'
@onready var camera_rig = $'../../CameraRig'
@onready var camera = $'../../CameraRig/Camera3D'
@onready var camera_raycast = $'../../CameraRaycastStim'
@onready var camera_raycast_target = $'../../CameraRaycastStim/Target'


func _load_animations(_schema, _prefix=''):
	
	var _animation_list = super._load_animations(_schema, _prefix)
	
	var sorted_animation_list = []
	sorted_animation_list.resize(_animation_list.size())

	for _animation in _animation_list:
		sorted_animation_list[attributes[_animation].direction] = _animation
	
	return sorted_animation_list


func _set_blendspace_position():
	
	var owner_rotation = owner.global_transform.basis.z
	var camera_rotation = -camera_raycast.global_transform.basis.z
	
	var facing_angle_x = camera_rotation.angle_to(
		owner_rotation.rotated(Vector3.UP, (PI / 2))
		)
	facing_angle_x = (PI / 2) - facing_angle_x
	
	var facing_angle_y = camera_rotation.angle_to(owner_rotation)
	facing_angle_y = (PI / 2) - facing_angle_y
	
	var facing_direction = Vector2(facing_angle_x, facing_angle_y).normalized()
	
	var x_value = facing_direction.x
	var x_max_value = 1
	var x_min_value = -1
	facing_direction.x = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min
	
	var y_value = facing_direction.y
	var y_max_value = 1
	var y_min_value = -1
	facing_direction.y = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min
	
	#facing_direction = data.direction
	
	behavior.set('parameters/BlendSpace2D/blend_position', facing_direction)


func _state_start():
	
	var model_pos = owner.global_transform.origin
	var target_pos = model_pos - owner.global_transform.basis * Vector3(data.direction.x, 0, data.direction.y)
	target_pos.y = model_pos.y
	
	camera_rig.clamp_camera = false
	var camera_rotation = camera.global_transform.basis
	
	owner.look_at(target_pos, Vector3.UP)
	
	camera.global_transform.basis = camera_rotation


func _ready():
	
	await super()
	
	await behavior.pre_advance
	
	x_min = behavior.blend_space_2d.get('min_space').x
	y_min = behavior.blend_space_2d.get('min_space').y
	x_value_range = behavior.blend_space_2d.get('max_space').x - behavior.blend_space_2d.get('min_space').x
	y_value_range = behavior.blend_space_2d.get('max_space').y - behavior.blend_space_2d.get('min_space').y


func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var result = tree_node._play_8way(_state, animation_list, attributes[animation_list[0]].duplicate(), new_data)
	
	return result
