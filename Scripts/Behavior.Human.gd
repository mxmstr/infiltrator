extends "res://Scripts/Behavior.gd"

export(String) var torso_bone
export(Array, String) var action_bones

var layer = Meta.BlendLayer.MOVEMENT
var can_zoom = false
var cached_action_pose

var action_up
var action_down
var transition
var blend_space_2d
var blend_space_up
var blend_space_upright
var blend_space_right
var blend_space_downright
var blend_space_down
var blend_space_downleft
var blend_space_left
var blend_space_upleft

onready var model = $'../Model'
onready var viewport = $'../Perspective/Viewport2D'
onready var movement = get_node_or_null('../Movement')
onready var stance = get_node_or_null('../Stance')
onready var camera_mode = get_node_or_null('../CameraMode')
onready var hud_mode = get_node_or_null('../HUDMode')
onready var anim_layer_movement = get_node_or_null('../AnimLayerMovement')
onready var weapon_target_lock = get_node_or_null('../WeaponTargetLock')
onready var bullet_time = get_node_or_null('../BulletTime')

signal pre_advance
signal post_advance


func _on_pre_draw(viewport_rid):
	
	if viewport_rid.get_id() == viewport.get_viewport_rid().get_id():
		
		for idx in range(model.get_child(0).get_bone_count()):
			
			var s_world_bone_name = model.get_child(0).get_bone_name(idx)
			
			if s_world_bone_name in ['Head', 'Neck']:
				
#				var global_pose = model.get_child(0).get_bone_global_pose_no_override(idx)
#				global_pose.basis = global_pose.basis.scaled(Vector3(0.01, 0.01, 0.01))
#				model.get_child(0).set_bone_global_pose_override(idx, global_pose, 1.0, true)
				
				var p_world = model.get_child(0).get_bone_pose(idx)
				p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
				model.get_child(0).set_bone_pose(idx, p_world)
#				prints(model.get_child(0).get_bone_pose(idx).basis.get_scale())


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


func _apply_time_scale(attributes):
	
	var time_scaled = true
	
	if attributes.has('time_scaled'):
		time_scaled = attributes.time_scaled

	if bullet_time and bullet_time.active and not time_scaled:
		if attributes.has('speed'):
			attributes.speed /= Engine.time_scale
		else:
			attributes.speed = 1 / Engine.time_scale


func _apply_human_attributes(attributes):
	
	enable_abilities = true
	layer = Meta.BlendLayer.MOVEMENT
	can_zoom = false
	
	var lock_stance = false
	var lock_movement = false
	var lock_rotation = false
	var align_model_to_aim = false
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
	
	if attributes.has('align_model_to_aim'):
		align_model_to_aim = attributes.align_model_to_aim
	
	if attributes.has('camera_mode'):
		camera_mode_state = attributes.camera_mode
	
	if attributes.has('hud_mode'):
		hud_mode_state = attributes.hud_mode
	
	stance.lock_stance = lock_stance
	stance.lock_rotation = lock_rotation
	stance.lock_movement = lock_movement
	weapon_target_lock.align_model = align_model_to_aim
	camera_mode._start_state(camera_mode_state)
	hud_mode._start_state(hud_mode_state)


func _play(new_state, animation, attributes, up_animation=null, down_animation=null):
	
	_apply_time_scale(attributes)
	
	if not ._play(new_state, animation, attributes):
		return false
	
	_apply_human_attributes(attributes)
	
	set('parameters/Transition/current', 0)
	#_set_action_blend(0)
	
	if up_animation:
		_set_animation_up(up_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_up('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	if down_animation:
		_set_animation_down(down_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_down('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	return true


func _play_8way(new_state, animation_list, attributes):
	
	_apply_time_scale(attributes)
	
	if not _apply_attributes(new_state, attributes):
		return false
	
	_apply_human_attributes(attributes)
	
	var animation_nodes = [
		blend_space_up,
		blend_space_upright,
		blend_space_right,
		blend_space_downright,
		blend_space_down,
		blend_space_downleft,
		blend_space_left,
		blend_space_upleft
		]
	
	for idx in range(8):
		animation_nodes[idx].scale = scale
		animation_nodes[idx].clip_start = clip_start
		animation_nodes[idx].clip_end = clip_end
		animation_nodes[idx].animation = animation_list[idx]
	
#	if current_state == 'Default':
#		return true
	
	set('parameters/Transition/current', 1)
	
	return true


func _get_blend_point_node(direction):
	
	for idx in range(blend_space_2d.get_blend_point_count()):
		
		if direction == blend_space_2d.get_blend_point_node(idx).resource_name:
			return blend_space_2d.get_blend_point_node(idx)


func _ready():
	
	VisualServer.connect('viewport_pre_draw', self, '_on_pre_draw')
	
	transition = tree_root.get_node('Transition')
	action_up = tree_root.get_node('ActionUp')
	action_down = tree_root.get_node('ActionDown')
	blend_space_2d = tree_root.get_node('BlendSpace2D')
	blend_space_up = _get_blend_point_node('Forward')
	blend_space_upright = _get_blend_point_node('ForwardRight')
	blend_space_right = _get_blend_point_node('Right')
	blend_space_downright = _get_blend_point_node('BackwardRight')
	blend_space_down = _get_blend_point_node('Backward')
	blend_space_downleft = _get_blend_point_node('BackwardLeft')
	blend_space_left = _get_blend_point_node('Left')
	blend_space_upleft = _get_blend_point_node('ForwardLeft')
	
	var anim_layer_player = anim_layer_movement.get_node('AnimationPlayer')
	
	for animation in anim_layer_player.get_animation_list():
		$AnimationPlayer.add_animation(animation, anim_layer_player.get_animation(animation))
	
	anim_layer_movement.anim_player = anim_layer_movement.get_path_to($AnimationPlayer)
	anim_layer_movement.tree_root = anim_layer_movement.tree_root.duplicate(true)
	anim_layer_movement.tree_root._ready(anim_layer_movement, null, 'parameters/', 'root')
	anim_layer_movement.active = true


func _process(delta):
	
	emit_signal('pre_advance', delta)
	
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
	
	emit_signal('post_advance', delta)
