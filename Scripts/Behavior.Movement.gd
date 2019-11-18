extends 'res://Scripts/StateMachine.gd'

export(String) var root_bone
export(Array, String) var movement_bones

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

var stand_tree = []
var crouch_tree = []


func _add_anim_nodes(root, path):
	
	var array = []
	
	for point in root.get_blend_point_count():
		
		var node = root.get_blend_point_node(point)
		var position = root.get_blend_point_position(point)
		var animation = $AnimationPlayer.get_animation(node.get_node('Animation').animation) if node is AnimationNodeBlendTree else null
		var blendspace = node if node is AnimationNodeBlendSpace1D else null
		var children = _add_anim_nodes(node, path + str(point) + '/') if node is AnimationNodeBlendSpace1D else null
		
		array.append({
			'path': path + str(point) + '/',
			'animation': animation,
			'blendspace': blendspace,
			'children': children,
			'position': position
			})
	
	return array


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


func _sync_blend_spaces():
	
	var velocity = $'../HumanMovement'.velocity
	velocity.y = 0
	
	var local_velocity = owner.global_transform.basis.xform_inv(velocity)
	local_velocity = local_velocity / $'../HumanMovement'.max_speed
	
	set('parameters/Standing/blend_position', -local_velocity.x)
	set('parameters/Standing/0/blend_position', local_velocity.z)
	set('parameters/Crouching/blend_position', -local_velocity.x)
	set('parameters/Crouching/2/blend_position', local_velocity.z)


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


func _filter_anim_events(nodes, blend_position, filter_all=false):
	
	var closest = null
	var min_dist = 2.0
	
	for node in nodes:
		
		var dist = abs(clamp(blend_position - node.position, -2, 2))
		
		if dist <= min_dist:
			min_dist = dist
			closest = node
	
	
	for node in nodes:
		
		if node.animation != null:
			
			if node.position == closest.position:

				for track in node.animation.get_track_count():
					node.animation.track_set_enabled(track, node.animation.track_get_type(track) != 2 if filter_all else true)

			else:

				for track in node.animation.get_track_count():
					node.animation.track_set_enabled(track, node.animation.track_get_type(track) != 2)
		
		
		if node.blendspace != null:
			
			var position = get(node.path + 'blend_position')
			
			if node.position == closest.position:
				_filter_anim_events(node.children, position, filter_all)
			else:
				_filter_anim_events(node.children, position, true)


func _unfilter_anim_events(nodes):
	
	for node in nodes:
		
		if node.animation != null:
			
			for track in node.animation.get_track_count():
				node.animation.track_set_enabled(track, true)
		
		if node.blendspace != null:
			
			_unfilter_anim_events(node.children)


func _on_pre_process():
	
	_filter_anim_events(
		stand_tree, 
		get('parameters/Standing/blend_position'),
		blend_mode == Inf.Blend.ACTION
		)

	_filter_anim_events(
		crouch_tree, 
		get('parameters/Crouching/blend_position'),
		blend_mode == Inf.Blend.ACTION
		)


func _on_post_process():
	
	_unfilter_anim_events(stand_tree)
	_unfilter_anim_events(crouch_tree)


func _on_state_starting(_name):
	
	var node = $'../Behavior'.tree_root.get_node(_name)
	
	if node.get('blend_mode') == null:
		return
	
	if blend_mode != node.blend_mode:
		_cache_move_pose()
	
	_cache_action_pose()
	
	blend_mode = node.blend_mode


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
	
	stand_tree = _add_anim_nodes(tree_root.get_node('Standing'), 'parameters/Standing/')
	crouch_tree = _add_anim_nodes(tree_root.get_node('Crouching'), 'parameters/Crouching/')
	
	var playback = $'../Behavior'.get('parameters/playback')
	playback.connect('state_starting', self, '_on_state_starting')
	
	connect('pre_process', self, '_on_pre_process')
	connect('post_process', self, '_on_post_process')
	
	
	_set_skeleton()
	#call_deferred('_set_skeleton')


func _process(delta):
	
	_sync_blend_spaces()
	
	_blend_skeletons(delta)