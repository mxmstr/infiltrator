extends 'res://Scripts/AnimationTree.gd'

export(String) var root_bone
export(Array, String) var movement_bones

const camera_rig_track_path = '../../Perspective'

var blend_mode = Inf.Blend.ACTION

var model_skeleton
var action_skeleton
var move_skeleton

var cached_action_pose = []
var cached_model_pose = []

var action_blend_amount = 0.0
var action_blend_speed = 0.1

var model_blend_amount = 0.0
var model_blend_speed = 0.5


func _cache_action_pose():
	
	action_blend_amount = 1.0
	cached_action_pose = []
	
	for idx in range(action_skeleton.get_bone_count()):
		cached_action_pose.append(action_skeleton.get_bone_global_pose(idx))


func _cache_move_pose():
	
	model_blend_amount = 1.0
	cached_model_pose = []
	
	for idx in range(model_skeleton.get_bone_count()):
		cached_model_pose.append(model_skeleton.get_bone_global_pose(idx))


func _blend_camera(delta):
	
	pass


func _blend_skeletons(delta):
	
	var bones = range(model_skeleton.get_bone_count())
	
	var layered = blend_mode == Inf.Blend.LAYERED
	var action_only = blend_mode == Inf.Blend.ACTION
	var movement_only = blend_mode == Inf.Blend.MOVEMENT
	
	
	for idx in bones:
		
		var bone_name = model_skeleton.get_bone_name(idx)
		var model_transform = model_skeleton.get_bone_global_pose(idx)
		var move_transform = move_skeleton.get_bone_global_pose(idx)
		var action_transform = action_skeleton.get_bone_global_pose(idx)
		
		
		if movement_only or (layered and bone_name in movement_bones):
			
			if bone_name == root_bone:
				model_transform = move_transform
			else:
				model_transform.basis = move_transform.basis
				
		else:
			
			if action_blend_amount > 0:

				action_transform = action_transform.interpolate_with(cached_action_pose[idx], action_blend_amount)

				action_blend_amount -= delta * action_blend_speed
				action_blend_amount = max(action_blend_amount, 0)
			
			
			if bone_name == root_bone:
				model_transform = action_transform
			else:
				model_transform.basis = action_transform.basis
		
		
		if model_blend_amount > 0:

			var blended_transform = model_transform.interpolate_with(cached_model_pose[idx], model_blend_amount)

			if bone_name == root_bone:
				model_transform = blended_transform
			else:
				model_transform.basis = blended_transform.basis

			model_blend_amount -= delta * model_blend_speed
			model_blend_amount = max(model_blend_amount, 0)
		
		
		model_skeleton.set_bone_global_pose(idx, model_transform)


func _on_pre_process():
	
	tree_root._filter_anim_events(blend_mode == Inf.Blend.ACTION)


func _on_post_process():
	
	tree_root._unfilter_anim_events()


func _on_state_starting(_name):
	
	var node = $'../Behavior'.tree_root.get_node(_name)
	
	if node.get('blend') == null:
		return
	
	if blend_mode != node.blend:
		_cache_move_pose()
	
	_cache_action_pose()
	
	blend_mode = node.blend


func _set_skeleton():
	
	model_skeleton = $'../Model'.get_child(0)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(model_skeleton)
	
	action_skeleton = model_skeleton.duplicate()
	move_skeleton = model_skeleton.duplicate()
	
	for child in action_skeleton.get_children() + move_skeleton.get_children():
		child.queue_free()
	
	
	$'../Model'.add_child(action_skeleton)
	$'../Model'.add_child(move_skeleton)
	
	$'../Behavior/AnimationPlayer'.root_node = $'../Behavior/AnimationPlayer'.get_path_to(action_skeleton)
	$AnimationPlayer.root_node = $AnimationPlayer.get_path_to(move_skeleton)
	
	
	active = true


func _ready():
	
	if not has_meta('unique'):
		return
	
	
	yield(get_tree(), 'idle_frame')
	
	var playback = $'../Behavior'.get('parameters/playback')
	playback.connect('state_starting', self, '_on_state_starting')

	connect('pre_process', self, '_on_pre_process')
	connect('post_process', self, '_on_post_process')
	
	_set_skeleton()


func _process(delta):
	
	#print([active, get('parameters/blend_position')])
	
	_blend_camera(delta)
	_blend_skeletons(delta)