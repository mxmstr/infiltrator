extends 'res://Scripts/AnimationTree.StateMachine.gd'

export(Meta.Priority) var priority
export(Meta.Visibility) var type
export(Meta.BlendLayer) var blend
export var cache_pose = true
export var distance = 0.0
export var enable_abilities = true
export var lock_stance = false
export var lock_speed = false
export var lock_direction = false
export var lock_rotation = false
export var lock_movement = false
export var camera_mode = 'LockYaw'
export var hud_mode = 'Default'

var stance
var camera_mode_node
var hud_mode_node
var anim_layer_movement


func _is_visible():
	
	return type != Meta.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	._on_state_starting(new_name)
	
	if node_name == new_name:
		
		var playback = owner.get(parent.parameters + 'playback')
		
		if len(playback.get_travel_path()) == 0:
			
			owner.enable_abilities = enable_abilities
			
			if stance:
				stance.lock_stance = lock_stance
				stance.lock_speed = lock_speed
				stance.lock_direction = lock_direction
				stance.lock_rotation = lock_rotation
				stance.lock_movement = lock_movement
			
			if camera_mode_node:
				camera_mode_node._start_state(camera_mode)
			
			if hud_mode_node:
				hud_mode_node._start_state(hud_mode)
			
			if anim_layer_movement:
				anim_layer_movement.blend_mode = blend
				anim_layer_movement.cache_poses = cache_pose


func _ready(_owner, _parent, _parameters, _name):
	
	._ready(_owner, _parent, _parameters, _name)
	
	stance = owner.owner.get_node_or_null('Stance')
	camera_mode_node = owner.owner.get_node_or_null('CameraMode')
	hud_mode_node = owner.owner.get_node_or_null('HUDMode')
	anim_layer_movement = owner.owner.get_node_or_null('AnimLayerMovement')