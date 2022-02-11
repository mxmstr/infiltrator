extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper', 'Grenade']

export(String) var shoot_schema
export(String) var shoot_idle_schema

var shoot_animations = {}
var shoot_idle_animations = {}

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _cock_weapon():
	
	if righthand._has_item_with_tag('Firearm'):
		
		righthand.items[0].get_node('Audio')._start_state('FireProjectileCock')


func _ready():
	
	if tree.is_empty():
		return
	
	for item_name in item_names:
		shoot_animations[item_name] = _load_animations('Shoot' + item_name)
		shoot_idle_animations[item_name] = _load_animations('Shoot' + item_name + 'Idle')


func _on_action(_state, data):
	
	if _state == 'UseItem':
		
		if not righthand._is_empty() and tree_node.current_state in ['Default', 'UseReact', 'ShootIdle']:
		
			Meta.StimulateActor(righthand.items[0], 'Use', owner)
	
	elif _state == 'UseReact':
		
		if righthand._has_item_with_tag('Firearm'):
			
			var item_name = righthand.items[0].base_name
			
			if shoot_animations.has(item_name):
				
				_play(_state, shoot_animations[item_name][0], shoot_animations[item_name][1], shoot_animations[item_name][2])
	
	elif _state == 'ShootIdle':
		
		if not righthand._is_empty():
			
			var item_name = righthand.items[0].base_name
			
			if shoot_idle_animations.has(item_name):
				
				if shoot_idle_animations[item_name].size() > 1:
					_play(_state, shoot_idle_animations[item_name][0], shoot_idle_animations[item_name][1], shoot_idle_animations[item_name][2])
				else:
					_play(_state, shoot_idle_animations[item_name][0])


func _process(delta):
	
	if righthand._has_item_with_tag('Firearm'):
		
		if tree_node.current_state == 'Default':
			
			_on_action('ShootIdle', {})
	
	else:
		
		if tree_node.current_state == 'ShootIdle':
			
			tree_node._start_state('Default')


	if tree_node.current_state in ['UseReact', 'ShootIdle']:

		var target_pos = camera_raycast_target.global_transform.origin
		var look_direction = camera_raycast.global_transform.origin.direction_to(target_pos).normalized()
		var look_angle = Vector3(0, -1, 0).angle_to(look_direction)

		tree_node._set_action_blend((rad2deg(look_angle) - 90) / 90)
