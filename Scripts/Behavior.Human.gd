extends "res://Scripts/Behavior.gd"

export(String) var torso_bone
export(Array, String) var action_bones

var layer = Meta.BlendLayer.MOVEMENT
var can_zoom = false
var cached_action_pose

var action_up
var action_down

onready var movement = get_node_or_null('../Movement')
onready var stance = get_node_or_null('../Stance')
onready var camera_mode = get_node_or_null('../CameraMode')
onready var hud_mode = get_node_or_null('../HUDMode')
onready var anim_layer_movement = get_node_or_null('../AnimLayerMovement')

signal pre_advance


func _set_layer(_layer):
	
	layer = _layer


func _set_action_blend(blend):
	
	set('parameters/ActionBlend/blend_amount', blend)


func _set_animation_up(animation, scale, clip_start, clip_end):
	
	action_up.scale = scale
	action_up.clip_start = clip_start
	action_up.clip_end = clip_end
	action_up.animation = animation


func _set_animation_down(animation, scale, clip_start, clip_end):
	
	action_down.scale = scale
	action_down.clip_start = clip_start
	action_down.clip_end = clip_end
	action_down.animation = animation


func _cache_action_pose():
	
	cached_action_pose = []
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == torso_bone:
			cached_action_pose.append(skeleton.get_bone_global_pose_no_override(idx))
		else:
			cached_action_pose.append(skeleton.get_bone_pose(idx))


func _apply_action_pose():
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == torso_bone:
			
			var global_pose = skeleton.get_bone_global_pose_no_override(idx)
			cached_action_pose[idx] = Transform(cached_action_pose[idx].basis, global_pose.origin)
			skeleton.set_bone_global_pose_override(idx, cached_action_pose[idx], 1.0, true)
			
		elif bone_name in action_bones:
			
			skeleton.set_bone_pose(idx, cached_action_pose[idx])


func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	if not ._play(new_state, animation, attributes):
		return false
	
	enable_abilities = true
	layer = Meta.BlendLayer.MOVEMENT
	can_zoom = false
	
	var lock_stance = false
	var lock_movement = false
	var lock_rotation = false
	var camera_mode_state = 'Default'
	var hud_mode_state = 'Default'
	
	if attributes.has('layer'):
		layer = Meta.BlendLayer[attributes.layer]
	
	if attributes.has('can_zoom'):
		can_zoom = attributes.can_zoom
	
	if attributes.has('enable_abilities'):
		enable_abilities = attributes.enable_abilities
	
	if attributes.has('lock_stance'):
		lock_stance = attributes.lock_stance
	
	if attributes.has('lock_rotation'):
		lock_rotation = attributes.lock_rotation
	
	if attributes.has('lock_movement'):
		lock_movement = attributes.lock_movement
	
	if attributes.has('camera_mode'):
		camera_mode_state = attributes.camera_mode
	
	if attributes.has('hud_mode'):
		hud_mode_state = attributes.hud_mode
	
	stance.lock_stance = lock_stance
	stance.lock_rotation = lock_rotation
	stance.lock_movement = lock_movement
	camera_mode._start_state(camera_mode_state)
	hud_mode._start_state(hud_mode_state)
	
	
	_set_action_blend(0)
	
	if up_animation:
		_set_animation_up(up_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_up('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	if down_animation:
		_set_animation_down(down_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_down('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	return true


func _ready():
	
	action_up = tree_root.get_node('ActionUp')
	action_down = tree_root.get_node('ActionDown')
	
	anim_layer_movement.anim_player = anim_layer_movement.get_path_to($AnimationPlayer)
	anim_layer_movement.tree_root = anim_layer_movement.tree_root.duplicate(true)
	anim_layer_movement.tree_root._ready(anim_layer_movement, null, 'parameters/', 'root')
	anim_layer_movement.active = true


func _process(delta):
	
	emit_signal('pre_advance')
	
	var is_action = layer == Meta.BlendLayer.ACTION
	var is_movement = layer == Meta.BlendLayer.MOVEMENT
	var is_mixed = layer == Meta.BlendLayer.MIXED

	if is_action or is_movement:
		skeleton.clear_bones_global_pose_override()

	if not is_movement:

		advance(delta)
		movement.call_deferred('_apply_root_transform', get_root_motion_transform(), delta)

		if is_mixed:
			_cache_action_pose()

	if not is_action:
		anim_layer_movement.advance(delta)

	if is_mixed:
		_apply_action_pose()

	
	skeleton.scale = Vector3(-1, -1, -1)
