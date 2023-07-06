extends 'res://Scripts/AnimationTree.gd'

@export var root_bone: String
@export var movement_bones: Array[String]

const camera_rig_track_path = '../../Perspective'

var blend_mode = Meta.BlendLayer.ACTION
var cache_poses = true

var model
var behavior
var behavior_animation_player
var animation_player
var model_skeleton
var action_skeleton
var move_skeleton

var bone_names = []
var cached_action_pose = []
var cached_model_pose = []

var action_blend_amount = 0.0
var action_blend_speed = 0.5

var model_blend_amount = 0.0
var model_blend_speed = 0.5


func _on_pre_process():
	
	tree_root._filter_anim_events(blend_mode == Meta.BlendLayer.ACTION)


func _on_post_process():
	
	tree_root._unfilter_anim_events()


func _on_state_starting(_name):
	
	var node = behavior.tree_root.get_node(_name)
	
	if not node.get('blend'):
		return
	
	
	if blend_mode != node.blend:
		_cache_move_pose()
	
	if cache_poses:
		_cache_action_pose()
	
	blend_mode = node.blend


func _cache_action_pose():
	
	action_blend_amount = 1.0
	cached_action_pose = []
	
	for idx in range(model_skeleton.get_bone_count()):
		cached_action_pose.append(model_skeleton.get_bone_global_pose(idx))


func _cache_move_pose():
	
	model_blend_amount = 1.0
	cached_model_pose = []
	
	for idx in range(model_skeleton.get_bone_count()):
		cached_model_pose.append(model_skeleton.get_bone_global_pose(idx))


func _blend_camera(delta):
	
	pass


func _blend_skeletons(delta):
	
	if not model_skeleton:
		return
	
	
	var bones = range(model_skeleton.get_bone_count())
	
#	var layered = blend_mode == Meta.BlendLayer.LAYERED
#	var action_only = blend_mode == Meta.BlendLayer.ACTION
#	var movement_only = blend_mode == Meta.BlendLayer.MOVEMENT
	
#	active = not action_only
	
	
	for idx in bones:
		
		var bone_name = model_skeleton.get_bone_name(idx)
		var model_transform = model_skeleton.get_bone_global_pose(idx)
		var move_transform = move_skeleton.get_bone_global_pose(idx)
#		var action_transform = action_skeleton.get_bone_global_pose(idx)
		
		
		if bone_name in movement_bones:
			model_skeleton.set_bone_global_pose_override(idx, move_transform, 1.0, true)
		
		
#		if movement_only or (layered and bone_name in movement_bones):
#
#			if bone_name == root_bone:
#				model_transform = move_transform
#			else:
#				model_transform.basis = move_transform.basis
#
#		else:
#
#			if action_blend_amount > 0:
#
#				action_transform = action_transform.interpolate_with(cached_action_pose[idx], action_blend_amount)
#
#				action_blend_amount -= delta * action_blend_speed
#				action_blend_amount = max(action_blend_amount, 0)
#
#
#			if bone_name == root_bone:
#				model_transform = action_transform
#			else:
#				model_transform.basis = action_transform.basis
#
#
#		if model_blend_amount > 0:
#
#			var blended_transform
#
#			blended_transform = model_transform.interpolate_with(cached_model_pose[idx], model_blend_amount)
#
#			if bone_name == root_bone:
#				model_transform = blended_transform
#			else:
#				model_transform.basis = blended_transform.basis
#
#			model_blend_amount -= delta * model_blend_speed
#			model_blend_amount = max(model_blend_amount, 0)
#
#
#		if bone_name in movement_bones:
#			model_skeleton.set_bone_global_pose(idx, model_transform)


func _set_skeleton():
	
	if not model:
		return
	
	
#	add_child(action_skeleton)
	add_child(move_skeleton)
	
#	behavior_animation_player.root_node = behavior_animation_player.get_path_to(action_skeleton)
	animation_player.root_node = animation_player.get_path_to(model_skeleton)#move_skeleton)
	
	
	active = true


func _enter_tree():
	
	model = get_node_or_null('../Model')
	animation_player = $AnimationPlayer
	
	if not model:
		return
	
	
	model_skeleton = model.get_child(0)
	
	for idx in range(model_skeleton.get_bone_count()):
		bone_names.append(model_skeleton.get_bone_name(idx))
	
#	action_skeleton = model_skeleton.duplicate()
	move_skeleton = model_skeleton.duplicate()
	
	for child in move_skeleton.get_children():# + action_skeleton.get_children():
		child.queue_free()


func _ready():
	
	behavior = get_node_or_null('../Behavior')
	behavior_animation_player = get_node_or_null('../Behavior/AnimationPlayer')
	
	if not model:
		
		set_process(false)
		set_physics_process(false)
		
		return
	
	
	await get_tree().idle_frame
	
#	var playback = behavior.get('parameters/playback')
#	playback.connect('state_starting',Callable(self,'_on_state_starting'))

#	connect('pre_process',Callable(self,'_on_pre_process'))
#	connect('post_process',Callable(self,'_on_post_process'))
	
	_set_skeleton()


func _process(delta):
	
	if not model:
		return
	
	_blend_camera(delta)
	_blend_skeletons(delta)
	
#	if blend_mode == Meta.BlendLayer.ACTION:
##		active = false
#		behavior.blend_with_skeleton(model_skeleton, root_bone, bone_names)
#	elif blend_mode == Meta.BlendLayer.LAYERED:
#		behavior.blend_with_skeleton(model_skeleton, root_bone, bone_names)
#		blend_with_skeleton(model_skeleton, root_bone, movement_bones)
#	elif blend_mode == Meta.BlendLayer.MOVEMENT:
#		blend_with_skeleton(model_skeleton, '', bone_names)
