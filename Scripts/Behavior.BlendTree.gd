extends "res://Scripts/AnimationTree.BlendTree.gd"

export(String, MULTILINE) var expression
export(Dictionary) var arguments
var exec_list = []

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

var playing = false
var stance
var camera_mode_node
var hud_mode_node
var anim_layer_movement


func _evaluate():
	
	for exec in exec_list:
		
		var result = exec.execute(arguments.values(), owner)
		
		if not result:
		
			if exec.has_execute_failed():
				
				prints(owner.owner.name, exec.get_error_text())
			
			return false
	
	return true


func _is_visible():
	
	return type != Meta.Visibility.INVISIBLE


func _on_state_starting(new_name):
	
	if node_name == new_name:
		
		playing = true
		
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
				anim_layer_movement.cache_poses = cache_pose
	
	else:
		
		playing = false
	
	._on_state_starting(new_name)


func _ready(_owner, _parent, _parameters, _node_name):
	
	._ready(_owner, _parent, _parameters, _node_name)
	
	stance = owner.owner.get_node_or_null('Stance')
	camera_mode_node = owner.owner.get_node_or_null('CameraMode')
	hud_mode_node = owner.owner.get_node_or_null('HUDMode')
	anim_layer_movement = owner.owner.get_node_or_null('AnimLayerMovement')
	
	for line in expression.split('\n'):
		
		var exec = Expression.new()
		exec.parse(line, arguments.keys())
		exec_list.append(exec)


func _process(delta):
	
	if parent and owner.get(parent.parameters + 'playback'):
		
		var playback = owner.get(parent.parameters + 'playback')
		
		if playback.is_playing() and playing:
		
			if anim_layer_movement:
				
				if _evaluate():
					anim_layer_movement.blend_mode = Meta.BlendLayer.LAYERED
				else:
					anim_layer_movement.blend_mode = Meta.BlendLayer.ACTION
	
	else:
		
		playing = false
	
	._process(delta)
