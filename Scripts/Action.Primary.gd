extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper', 'Grenade']
const dual_wield_items = ['Beretta', 'DesertEagle', 'Ingram']

export(String) var shoot_schema

var shoot_animations = {}
var shoot_idle_animations = {}
var shoot_dual_animations = {}
var shoot_dual_idle_animations = {}

onready var behavior = get_node_or_null('../Behavior')
onready var righthand = get_node_or_null('../RightHandContainer')
onready var lefthand = get_node_or_null('../LeftHandContainer')
onready var camera_raycast = get_node_or_null('../CameraRig/Camera')
onready var camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')


func _use_left_hand_item():
	
	lefthand.items.size()
	if not lefthand._is_empty() and tree_node.current_state in ['Default', 'UseReact', 'ShootIdle']:
		Meta.StimulateActor(lefthand.items[0], 'Use', owner)


func _cock_weapon():
	
	if righthand._has_item_with_tag('Firearm'):
		
		righthand.items[0].get_node('Audio')._start_state('FireProjectileCock')


func _ready():
	
	if tree.is_empty():
		return
	
	for item_name in item_names:
		
		shoot_animations[item_name] = _load_animations(shoot_schema + item_name)
		shoot_idle_animations[item_name] = _load_animations(shoot_schema + item_name + 'Idle')
		
		if item_name in dual_wield_items:
			shoot_dual_animations[item_name] = _load_animations(shoot_schema + item_name + 'Dual')
			shoot_dual_idle_animations[item_name] = _load_animations(shoot_schema + item_name + 'DualIdle')


func _on_action(_state, data):
	
	if _state == 'UseItem':
		
		if not righthand._is_empty() and tree_node.current_state in ['Default', 'UseReact', 'ShootIdle']:
		
			Meta.StimulateActor(righthand.items[0], 'Use', owner)
	
	elif _state == 'UseReact':
		
		if righthand._has_item_with_tag('Firearm'):
			
			var right_name = righthand.items[0].base_name
			var left_name = '' if lefthand._is_empty() else lefthand.items[0].base_name
			var dual_wielding = right_name in dual_wield_items and right_name == left_name
			
			if shoot_animations.has(right_name):
				
				var animation_list
				
				if dual_wielding:
					animation_list = shoot_dual_animations[right_name]
				else:
					animation_list = shoot_animations[right_name]
				
				_play(_state, animation_list[0], animation_list[1], animation_list[2])
				
				if dual_wielding and right_name == 'Ingram':
					_use_left_hand_item()
	
	elif _state == 'ShootIdle':
		
		if not righthand._is_empty():
			
			var right_name = righthand.items[0].base_name
			var left_name = ''
			
			lefthand.items.size()
			if not lefthand._is_empty():
				left_name = lefthand.items[0].base_name
			
			if shoot_idle_animations.has(right_name):
				
				var animation_list
				
				if right_name in dual_wield_items and right_name == left_name:
					animation_list = shoot_dual_idle_animations[right_name]
				else:
					animation_list = shoot_idle_animations[right_name]
				
				if animation_list.size() == 3:
					_play(_state, animation_list[0], animation_list[1], animation_list[2])
				else:
					_play(_state, animation_list[0])


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
