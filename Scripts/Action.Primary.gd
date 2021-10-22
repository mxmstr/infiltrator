extends "res://Scripts/Action.gd"

export(String) var shoot_schema
export(String) var shoot_idle_schema

var shoot_animation_list = []
var shoot_idle_animation_list = []

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _ready():
	
	if tree.is_empty():
		return
	
	shoot_animation_list = _load_animations(shoot_schema)
	shoot_idle_animation_list = _load_animations(shoot_idle_schema)


func _on_action(state, data):
	
	._on_action(state, data)
	
	if state == 'UseReact':
		
		if righthand._has_item_with_tag('Firearm'):
			
			_play(shoot_animation_list[0], shoot_animation_list[1], shoot_animation_list[2])


func _process(delta):
	
	if righthand._has_item_with_tag('Firearm') and tree_node.current_state == 'Default':
		
		state = 'ShootIdle'
		_play(shoot_idle_animation_list[0], shoot_idle_animation_list[1], shoot_idle_animation_list[2])
	
	
	if tree_node.current_state in ['UseReact', 'ShootIdle']:
		
		var target_pos = camera_raycast_target.global_transform.origin
		var look_direction = camera_raycast.global_transform.origin.direction_to(target_pos).normalized()
		var look_angle = Vector3(0, -1, 0).angle_to(look_direction)
		
		tree_node._set_action_blend((rad2deg(look_angle) - 90) / 90)