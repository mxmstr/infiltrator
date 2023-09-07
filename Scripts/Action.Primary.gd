extends "res://Scripts/Action.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper', 'Grenade']
const dual_wield_items = ['Beretta', 'DesertEagle', 'Ingram', 'SawedoffShotgun']

@export var shoot_schema: String

var shoot_animations = {}
var shoot_idle_animations = {}
var shoot_dual_animations = {}
var shoot_dual_idle_animations = {}

@onready var righthand = get_node_or_null('../../RightHandContainer')
@onready var lefthand = get_node_or_null('../../LeftHandContainer')
@onready var camera_raycast = get_node_or_null('../../CameraRig/Camera3D')
@onready var camera_raycast_target = get_node_or_null('../../CameraRaycastStim/Target')


func _use_right_hand_item():
	
	righthand.items.size()
	
	if not righthand._is_empty() and tree_node.can_use_item:
		
		var item = righthand.items[0]
		
		if not lefthand._is_empty():
			
			if item._has_tag('DualWieldFireDelay'):
				get_tree().create_timer(float(item._get_tag('DualWieldFireDelay'))).connect('timeout',Callable(self,'_use_left_hand_item'))
			else:
				_use_left_hand_item()
		
		ActorServer.Stim(item, 'Use', owner)


func _use_left_hand_item():
	
	lefthand.items.size()
	
	if not lefthand._is_empty() and tree_node.can_use_item:
		ActorServer.Stim(lefthand.items[0], 'Use', owner)


func _cock_weapon():
	
	if righthand._has_item_with_tag('Firearm'):
		
		righthand.items[0].get_node('Audio')._start_state('FireProjectileCock')


func _ready():
	
	await super()
	
	for item_name in item_names:
		
		shoot_animations[item_name] = _load_animations(shoot_schema + item_name, item_name + '_')
		shoot_idle_animations[item_name] = _load_animations(shoot_schema + item_name + 'Idle', item_name + '_')
		
		if item_name in dual_wield_items:
			shoot_dual_animations[item_name] = _load_animations(shoot_schema + item_name + 'Dual', item_name + 'Dual_')
			shoot_dual_idle_animations[item_name] = _load_animations(shoot_schema + item_name + 'DualIdle', item_name + 'Dual_')


func _on_action(_state, data):
	
	if _state == 'UseItem':
		
		_use_right_hand_item()
	
	elif _state == 'UseReact':
		
		if righthand._has_item_with_tag('Firearm'):
			
			var right_name = righthand.items[0].base_name
			var left_name = '' if lefthand._is_empty() else lefthand.items[0].base_name
			var dual_wielding = right_name in dual_wield_items and right_name == left_name
			
			if shoot_animations.has(right_name):
				
				var animation_list
				var prefix
				
				if dual_wielding:
					animation_list = shoot_dual_animations[right_name]
					prefix = right_name + 'Dual_'
				else:
					animation_list = shoot_animations[right_name]
					prefix = right_name + '_'
				
				_play(_state, animation_list[0], prefix, animation_list[1], animation_list[2])
				
				if dual_wielding and right_name == 'Ingram':
					_use_left_hand_item()
	
	elif _state == 'ShootIdle':
		
		if not righthand._is_empty():
			
			var right_name = righthand.items[0].base_name
			var left_name = ''
			
			lefthand.items.size()
			if not lefthand._is_empty():
				left_name = lefthand.items[0].base_name
			
			var dual_wielding = right_name in dual_wield_items and right_name == left_name
			
			if shoot_idle_animations.has(right_name):
				
				var animation_list
				var prefix
				
				if dual_wielding:
					animation_list = shoot_dual_idle_animations[right_name]
					prefix = right_name + 'Dual_'
				else:
					animation_list = shoot_idle_animations[right_name]
					prefix = right_name + '_'
				
				if animation_list.size() == 3:
					_play(_state, animation_list[0], prefix, animation_list[1], animation_list[2])
				else:
					_play(_state, animation_list[0], prefix)


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
		
		tree_node._set_action_blend((rad_to_deg(look_angle) - 90) / 90)
