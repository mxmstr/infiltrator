extends AnimationTree

export(String) var root_bone
export(Array, String) var movement_bones
export(Array, String) var fp_hidden_bones

var cached_pose = []
var anim_nodes = []


func _set_bone_y_rotation(bone_name, y_rot, root=false):
	
	var s_action = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	
	
	var bone = s_action.find_bone(bone_name)
	var bone_transform = s_action.get_bone_rest(bone) if root else s_action.get_bone_global_pose(bone)
	var rotate_amnt = y_rot - s_action.global_transform.basis.get_euler().y
	bone_transform = bone_transform.rotated(Vector3(0, 1, 0), rotate_amnt)
	s_action.set_bone_global_pose(bone, bone_transform)


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


func _ready():
	
	var skeleton = $'../../Model'.get_children()[0].duplicate()
	
	for child in skeleton.get_children():
		child.queue_free()
	
	
	get_parent().call_deferred('add_child', skeleton)
	$AnimationPlayer.root_node = NodePath('../../' + skeleton.name)
	
	
	var blendspace = tree_root.get_node('BlendTree').get_node('BlendSpace1D')
	anim_nodes = _add_anim_nodes(blendspace, 'parameters/BlendTree/BlendSpace1D/')
	
	active = true


func _filter_anim_events(nodes, blend_position, filter_all=false):
	
	var closest = null
	var min_dist = 2.0
	
	for node in nodes:
		
		var dist = abs(blend_position - node.position)
		
		if dist < min_dist:
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


func _sync_blend_spaces():
	
	var velocity = $'../../HumanMovement'.velocity
	velocity.y = 0
	
	var local_velocity = $'../../'.global_transform.basis.xform_inv(velocity)
	local_velocity = local_velocity / $'../../HumanMovement'.max_speed
	
	set('parameters/BlendTree/BlendSpace1D/blend_position', -local_velocity.x)
	set('parameters/BlendTree/BlendSpace1D/0/blend_position', local_velocity.z)


func _blend_skeletons():
	
	var s_movement = $AnimationPlayer.get_node($AnimationPlayer.root_node)
	var s_action = $'../AnimationPlayer'.get_node($'../AnimationPlayer'.root_node)
	var layered = get_parent().blend_mode == Infiltrator.blend.LAYERED
	var action_only = get_parent().blend_mode == Infiltrator.blend.ACTION
	var movement_only = get_parent().blend_mode == Infiltrator.blend.MOVEMENT
	
	for idx in range(s_action.get_bone_count()):
		cached_pose.append(s_action.get_bone_global_pose(idx))
	
	
	for idx in range(s_action.get_bone_count()):
		var bone_name = s_action.get_bone_name(idx)
		var move_transform = s_movement.get_bone_global_pose(idx)
		var action_transform = s_action.get_bone_global_pose(idx)
		
		
		if not action_only:
		
			if movement_only or bone_name in movement_bones:
				if bone_name == root_bone:
					action_transform = move_transform
				else:
					action_transform.basis = move_transform.basis
				s_action.set_bone_global_pose(idx, action_transform)
				
			else:
				action_transform.basis = cached_pose[idx].basis
				s_action.set_bone_global_pose(idx, action_transform)
		
		
		if bone_name in fp_hidden_bones:
			action_transform = s_action.get_bone_pose(idx)
			action_transform.basis = action_transform.basis.scaled(Vector3(0.01, 0.01, 0.01))
			s_action.set_bone_pose(idx, action_transform)


func _process(delta):
	
	_sync_blend_spaces()
	
	_filter_anim_events(anim_nodes, get('parameters/BlendTree/BlendSpace1D/blend_position'))
	
	_blend_skeletons()
	